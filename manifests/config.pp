# == Class: zookeeper::config
#
# Configuration class for zookeeper. Allows you to specify a configuration for
# zookeeper nodes. Generally not launched directly.
#
# === Parameters
#
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
# [*group*]
#   Which zookeeper group this configuration is a member of.
# [*myid*]
#   An ID to identify the particular zookeeper server. Defaults to a rand.
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
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class zookeeper::config (
  $homedir         = $zookeeper::params::zookeeper_home,
  $datadir         = $zookeeper::params::zookeeper_datadir,
  $logdir          = $zookeeper::params::zookeeper_logdir,
  $clientport      = $zookeeper::params::zookeeper_clientport,
  $server_list     = $zookeeper::params::server_list,
  $group           = 'default',
  $myid            = fqdn_rand(50),
) {

  #File definition for the home folder for zookeeper
  file { $homedir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  #Zookeeper datadir
  file { $datadir:
    ensure   => directory,
    owner    => 'root',
    group    => 'root',
    require  => File[$homedir],
  }

  #Log folder
  file { $logdir:
    ensure   => directory,
    owner    => 'root',
    group    => 'root',
    require  => File[$homedir],
  }

  #Define zookeeper config file for cluster
  concat { "${homedir}/conf/zoo.cfg":
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Exec['zookeeper-install'],
  }
  concat::fragment { '00_zookeeper_header':
    target  => "${homedir}/conf/zoo.cfg",
    order   => '01',
    content => template('zookeeper/zoo.cfg.header.erb'),
  }

  #Add myid file to each node configured
  file { "${datadir}/myid":
    ensure  => present,
    content => $myid,
    require => File[$datadir],
  }

  if (size($server_list) == 0) {
    #Collect exported servers and realize to the zookeeper config file
    Zookeeper::Servernode <<| group == $group |>>
  } else {
    # Use a custom list of servers, in the form of an array
    zookeeper::servernode {
      $server_list:
        group => $group
    }
  }

}
