# == Class: zookeeper::server
#
# Launches a server for zookeeper. Don't use directly
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
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
