class zookeeper::server {

  exec { 'zookeeper-start':
    command => 'zkServer.sh restart',
    cwd     => "${zookeeper::params::zookeeper_home}/bin",
    path    => ['/bin', '/sbin', '/usr/bin', '/usr/sbin',
                "${zookeeper::params::zookeeper_home}/bin"
               ],
    require => File[$zookeeper::params::zookeeper_home],
    unless  => "netstat -ln | grep ':3888'",
  }

}
