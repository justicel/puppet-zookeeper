define zookeeper::servernode (
  $server_name = $name,
  $group       = 'default',
  $home        = $zookeeper::params::home,
  $myid        = fqdn_rand(50),
) {

  include zookeeper::params

  concat::fragment { "${group}_zookeeper_service_${name}":
    order   => "10-${group}-${server_name}",
    target  => "${home}/conf/zoo.cfg",
    content => template('zookeeper/zoonode.erb'),
  }

}
