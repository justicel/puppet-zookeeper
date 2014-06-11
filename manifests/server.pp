# == Class: zookeeper::server
#
# Launches a server for zookeeper. Don't use directly
#
# === Parameters
#
# [*install_method*]
#   Available Options - wget, deb
#   Specify the installation method. Defaults to a combination of wget/exec calls
#   to retrieve JARs from Zookeeper mirror.
#   If the deb method is specified, this will use a .deb package instead.
#   For deb, all paths are based on the output of "ant deb" run against Zookeeper sources.
# [*manage_service*]
#   Applicable when using install_method = deb. If set to true, service resource will be created.
#   Defaults to true.
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
# Nathan Sullivan <nathan@nightsys.net>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class zookeeper::server (
  $install_method = $zookeeper::params::install_method,
  $manage_service = $zookeeper::params::manage_service,
) {
  case $install_method {
    'wget': {
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
    'deb': {
      if ($manage_service == true) {
        service {
          'zookeeper':
            ensure     => running,
            enable     => true,
            hasrestart => true,
            hasstatus  => true,
            require    => Package['zookeeper'],
        }
      }
    }
    default: {
      crit('Undefined or invalid input parameter install_method, cannot proceed')
    }
  }
}
