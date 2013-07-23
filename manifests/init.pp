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
  $homedir      = $zookeeper::params::zookeeper_home,
  $datadir      = $zookeeper::params::zookeeper_datadir,
  $logdir       = $zookeeper::params::zookeeper_logdir,
  $clientport   = $zookeeper::params::zookeeper_clientport,
  $server_name  = $::fqdn,
  $server_group = 'default',
) inherits zookeeper::params
{

  #Add node to cluster with stored config
  @@zookeeper::servernode { $server_name:
    group   => $server_group,
    homedir => $homedir,
  }

  #Download and install the zookeeper source
  class { 'zookeeper::install':
    version     => $version,
    homedir     => $homedir,
    datadir     => $datadir,
    logdir      => $logdir,
  }

  class { 'zookeeper::config':
    homedir    => $homedir,
    datadir    => $datadir,
    logdir     => $logdir,
    clientport => $clientport,
    group      => $server_group,
  }

  class { 'zookeeper::server': }

}
