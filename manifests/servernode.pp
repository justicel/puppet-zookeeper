define zookeeper::servernode (
  $server_name = $name,
  $group       = 'default',
  $homedir     = $zookeeper::params::home,
  $myid        = fqdn_rand(50),
) {

  include zookeeper::params

  concat::fragment { "${group}_zookeeper_service_${name}":
    order   => "10-${group}-${server_name}",
    target  => "${homedir}/conf/zoo.cfg",
    content => template('zookeeper/zoonode.erb'),
  }

}
