# == Class: zookeeper::servernode
#
# Defines a zookeeper node into the cluster. Generally not launched directly.
#
# === Parameters
#
# [*server_name*]
#   The name of the server you are launching. Could be ip, fqdn, etc.
# [*group*]
#   The group this server should live in.
# [*homedir*]
#   Where zookeeper lives.
# [*myid*]
#   A randomized ID to define this server in the cluster
# === Examples
#
#  class { 'zookeeper::servernode':
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
define zookeeper::servernode (
  $server_name = $name,
  $group       = 'default',
  $homedir     = $zookeeper::params::zookeeper_home,
  $myid        = fqdn_rand(50),
) {

  include zookeeper::params

  concat::fragment { "${group}_zookeeper_service_${name}":
    order   => "10-${group}-${server_name}",
    target  => "${homedir}/conf/zoo.cfg",
    content => template('zookeeper/zoonode.erb'),
  }

}
