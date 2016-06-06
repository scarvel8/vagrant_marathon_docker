include apt

class hosts ($hosts = hiera_hash("mmdnode_hosts") ) {
   create_resources('host', $hosts)
}

class { "hosts": }

module { 'puppetlabs/apt':
  ensure => 'present',
}

apt::key { 'mesosphere':
   id     => 'E56151BF',
   server => 'hkp://keyserver.ubuntu.com:80'
}

apt::ppa { 'ppa:webupd8team/java':
   require => Apt::Key['mesosphere']
}

apt::source { 'mesosphere':
   comment  => 'Mesosphere repo for marathon, mesos, and zookeeper',
   location => 'http://repos.mesosphere.com/ubuntu',
   repos    => 'main',
   notify   => Exec['apt_update']
}

class { 'zookeeper':
   servers => hiera('zookeeper_servers'),
   require => Apt::Source['mesosphere']
}

class { 'mesos':
   zookeeper => hiera('zookeeper_servers'),
   require => [ Apt::Source['mesosphere'], Package['mesos'] ]
}

class { 'mesos::master':
   work_dir => '/var/lib/mesos',
   options => {
       quorum => 2
   },
   single_role => false,
   require => [ Apt::Source['mesosphere'], Package['mesos'] ]
} 

class{ 'mesos::slave':
   attributes => {
     'env' => 'production',
   },
   resources => {
     'ports' => '[10000-65535]'
   },
   options   => {
     'containerizers' => 'docker,mesos',
     'hostname'       => $::fqdn,
   },
   require => [ Apt::Source['mesosphere'], Package['mesos'] ]
}

class { 'docker':
   ensure => 'latest',
   require => [ Apt::Source['mesosphere'] ]
}

class mesos::master::marathon {
   package { 'marathon':
      ensure => latest,
      require => Apt::Source['mesosphere'],
   }

   service { 'marathon':
      ensure => running,
      enable => true,
      require => Package['marathon'],
   }
}

class { "mesos::master::marathon": } 
