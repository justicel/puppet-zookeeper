# == Class: zookeeper
#
# Defines a default cluster member for zookeeper and configures it
#
# === Parameters
#
# [*install_method*]
#   Available Options - wget, deb
#   Specify the installation method. Defaults to a combination of wget/exec calls
#   to retrieve JARs from Zookeeper mirror.
#   If the deb method is specified, this will use a .deb package instead.
#   For deb, all paths are based on the output of "ant deb" run against Zookeeper sources.
# [*version*]
#   The version of zookeeper to install.
#   If install_method = wget, format should be a version number. Example - 3.4.6
#   If install_method = deb, format should be a debian package version number. Example - 3.4.6-1
# [*manage_java*]
#   Boolean, which determines if this module depends on the Java package being installed.
#   Defaults to true.
# [*manage_service*]
#   Applicable when using install_method = deb. If set to true, service resource will be created.
#   Defaults to true.
# [*service_user*]
#   Applicable when using install_method = deb. Defines the user that will own the data and process.
# [*homedir*]
#   Only applicable if install_method = wget.
#   Defines where the zookeeper 'home' folder will be. Default param used.
# [*datadir*]
#   Where to store the zookeeper data files. Can be different from home.
# [*logdir*]
#   Storage location for all of the zookeeper logs. Generally should be the
#   home-folder.
# [*clientport*]
#   The port used for communications with the zookeeper cluster by client
#   scripts or programs.
# [*server_list*]
#   A hash of servers, used in place of exported resources. Can be provided from anywhere
#   (eg. an alternative service discovery system). Keys are "myid" entries, and values
#   are the hostnames.
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
# Nathan Sullivan <nathan@nightsys.net>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class zookeeper (
  $install_method = $zookeeper::params::install_method,
  $version        = $zookeeper::params::zookeeper_version,
  $manage_java    = $zookeeper::params::manage_java,
  $manage_service = $zookeeper::params::manage_service,
  $service_user   = undef,
  $homedir        = undef,
  $datadir        = undef,
  $logdir         = undef,
  $clientport     = $zookeeper::params::zookeeper_clientport,
  $server_list    = $zookeeper::params::server_list,
  $server_name    = $::fqdn,
  $server_group   = 'default',
) inherits zookeeper::params
{
  # Validate some input.
  validate_string($version)
  validate_bool($manage_java)
  validate_bool($manage_service)
  validate_hash($server_list)
  validate_string($server_name)
  validate_string($server_group)

  # Determine which values we will use for homedir/datadir/logdir based on install_method.
  case $install_method {
    'wget': {
      if ($service_user == undef) {
        $use_service_user = $zookeeper::params::zookeeper_wget_user
      } else {
        $use_service_user = $service_user
      }
      if ($homedir == undef) {
        $use_homedir = $zookeeper::params::zookeeper_wget_homedir
      } else {
        $use_homedir = $homedir
      }
      if ($datadir == undef) {
        $use_datadir = $zookeeper::params::zookeeper_wget_datadir
      } else {
        $use_datadir = $datadir
      }
      if ($logdir == undef) {
        $use_logdir = $zookeeper::params::zookeeper_wget_logdir
      } else {
        $use_logdir = $logdir
      }
    }
    'deb': {
      if ($service_user == undef) {
        $use_service_user = $zookeeper::params::zookeeper_deb_user
      } else {
        $use_service_user = $service_user
      }
      if ($homedir == undef) {
        $use_homedir = $zookeeper::params::zookeeper_deb_homedir
      } else {
        $use_homedir = $homedir
      }
      if ($datadir == undef) {
        $use_datadir = $zookeeper::params::zookeeper_deb_datadir
      } else {
        $use_datadir = $datadir
      }
      if ($logdir == undef) {
        $use_logdir = $zookeeper::params::zookeeper_deb_logdir
      } else {
        $use_logdir = $logdir
      }
    }
    default: {
      crit('Undefined or invalid input parameter install_method, cannot proceed')
    }
  }

  #Add node to cluster with stored config
  if (zookeeper_servers_list_empty($server_list) == true) {
    # Only required if we are not using the custom server_list parameter.
    @@zookeeper::servernode { $server_name:
      group   => $server_group,
      homedir => $use_homedir,
    }
  }

  #Download and install the zookeeper source
  class { 'zookeeper::install':
    install_method => $install_method,
    version        => $version,
    manage_java    => $manage_java,
    homedir        => $use_homedir,
    datadir        => $use_datadir,
    logdir         => $use_logdir,
  }

  class { 'zookeeper::config':
    install_method => $install_method,
    service_user   => $use_service_user,
    homedir        => $use_homedir,
    datadir        => $use_datadir,
    logdir         => $use_logdir,
    clientport     => $clientport,
    server_list    => $server_list,
    group          => $server_group,
  }

  class { 'zookeeper::server':
    install_method => $install_method,
    manage_service => $manage_service,
  }
}
