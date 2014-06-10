# == Class: zookeeper
#
# Defines a default cluster member for zookeeper and configures it
#
# === Parameters
#
# [*version*]
#   The version of zookeeper to install.
# [*homedir*]
#   Defines where the zookeeper 'home' folder will be. Default param used.
# [*datadir*]
#   Where to store the zookeeper data files. Can be different from home.
# [*logdir*]
#   Storage location for all of the zookeeper logs. Generally should be the
#   home-folder.
# [*clientport*]
#   The port used for communications with the zookeeper cluster by client
#   scripts or programs.
# [*server_name*]
#   The actual name to use to identify the particular server-node.
# [*server_group*]
#   Which zookeeper group this configuration is a member of.
#
# === Examples
#
#  class { 'zookeeper':
#    version      => '0.0.1',
#    server_name  => $::fqdn,
#    server_group => 'default',
#  }
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class zookeeper (
  $version      = $zookeeper::params::zookeeper_version,
  $manage_java  = $zookeeper::params::manage_java,
  $homedir      = $zookeeper::params::zookeeper_home,
  $datadir      = $zookeeper::params::zookeeper_datadir,
  $logdir       = $zookeeper::params::zookeeper_logdir,
  $clientport   = $zookeeper::params::zookeeper_clientport,
  $server_list  = $zookeeper::params::server_list,
  $server_name  = $::fqdn,
  $server_group = 'default',
) inherits zookeeper::params
{
  validate_array($server_list)

  #Add node to cluster with stored config
  if (size($server_list) == 0) {
    # Only required if we are not using the custom server_list parameter.
    @@zookeeper::servernode { $server_name:
      group   => $server_group,
      homedir => $homedir,
    }
  }

  #Download and install the zookeeper source
  class { 'zookeeper::install':
    version     => $version,
    manage_java => $manage_java,
    homedir     => $homedir,
    datadir     => $datadir,
    logdir      => $logdir,
  }

  class { 'zookeeper::config':
    homedir     => $homedir,
    datadir     => $datadir,
    logdir      => $logdir,
    clientport  => $clientport,
    server_list => $server_list,
    group       => $server_group,
  }

  class { 'zookeeper::server': }

}
