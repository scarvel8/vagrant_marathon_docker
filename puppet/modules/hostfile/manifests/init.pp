class hostfile( $custom_hosts = hiera('mmd_hosts',{}) ) {
   create_resources host, $custom_hosts
}
