# == Class: zookeeper::config
#
# Configuration class for zookeeper. Allows you to specify a configuration for
# zookeeper nodes. Generally not launched directly.
#
# === Parameters
#
# [*install_method*]
#   Available Options - wget, deb
#   Specify the installation method. Defaults to a combination of wget/exec calls
#   to retrieve JARs from Zookeeper mirror.
#   If the deb method is specified, this will use a .deb package instead.
#   For deb, all paths are based on the output of "ant deb" run against Zookeeper sources.
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
# [*group*]
#   Which zookeeper group this configuration is a member of.
# [*myid*]
#   An ID to identify the particular zookeeper server. Defaults to a rand.
#   Only used if server_list is empty, otherwise myid is populated via server_list.
#
# === Examples
#
#  class { 'zookeeper::config':
#    group => 'clustertwo',
#    myid  => '1',
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
class zookeeper::config (
  $install_method  = $zookeeper::params::install_method,
  $service_user    = undef,
  $homedir         = undef,
  $datadir         = undef,
  $logdir          = undef,
  $clientport      = $zookeeper::params::zookeeper_clientport,
  $server_list     = $zookeeper::params::server_list,
  $group           = 'default',
  $myid            = undef
) {
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
      #File definition for the home folder for zookeeper
      file { $use_homedir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
      }
      $zookeeper_cfg_filename = "${use_homedir}/conf/zoo.cfg"
      $homedir_require = [File[$use_homedir]]
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
      $zookeeper_cfg_filename = '/etc/zookeeper/zoo.cfg'
      $homedir_require = [Package['zookeeper']]
    }
    default: {
      crit('Undefined or invalid input parameter install_method, cannot proceed')
    }
  }

  #Handle myid correctly based on the way we are finding our server list (externally specified or exported resources).
  if ($myid != undef) {
    $use_myid = $myid
  } elsif (zookeeper_servers_list_empty($server_list) == true) {
    $use_myid = fqdn_rand(50)
  } else {
    $use_myid = get_zookeeper_server_id($server_list, $::fqdn)
  }

  #Zookeeper datadir
  file { $use_datadir:
    ensure   => directory,
    owner    => $use_service_user,
    group    => $use_service_user,
    require  => $homedir_require,
  }

  #Log folder
  file { $use_logdir:
    ensure   => directory,
    owner    => $use_service_user,
    group    => $use_service_user,
    require  => $homedir_require,
  }

  #Define zookeeper config file for cluster
  # TODO - fix path for both install methods.
  concat { $zookeeper_cfg_filename:
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Exec['zookeeper-install'],
  }
  concat::fragment { '00_zookeeper_header':
    target  => $zookeeper_cfg_filename,
    order   => '01',
    content => template('zookeeper/zoo.cfg.header.erb'),
  }

  #Add myid file to each node configured
  file { "${use_datadir}/myid":
    ensure  => present,
    owner   => $use_service_user,
    group   => $use_service_user,
    content => $use_myid,
    require => File[$use_datadir],
  }

  if (zookeeper_servers_list_empty($server_list) == true) {
    #Collect exported servers and realize to the zookeeper config file
    Zookeeper::Servernode <<| group == $group |>>
  } else {
    $formatted_servers_list = format_zookeeper_servers_and_ids($server_list)
    # Use a custom list of servers, in the form of an array
    zookeeper::servernode {
      $formatted_servers_list:
        group        => $group,
        cfg_filename => $zookeeper_cfg_filename
    }
  }

}
