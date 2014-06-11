# == Class: zookeeper::servernode
#
# Defines a zookeeper node into the cluster. Generally not launched directly.
#
# === Parameters
#
# [*server_name*]
#   The name of the server you are launching. Could be ip, fqdn, etc.
#   There is another format, where you can specify myid:fqdn.
#   Using the second format takes precedent over separate myid parameter.
# [*group*]
#   The group this server should live in.
# [*homedir*]
#   Where zookeeper lives.
# [*myid*]
#   A randomized ID to define this server in the cluster.
#   Only used with exported resources.
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

  # Different styles of handling user input.
  # 1) Involves $server_name being the FQDN, with $myid generated accordingly.
  #    Specific to exported resources use case.
  # 2) Involves $server_name containing a string like "myid:fqdn", that can be split.
  #    Used when a hash of servers is provided (from some external source).
  if ($server_name =~ /:/) {
    $split_server_name = split($server_name, ':')
    $use_myid = $split_server_name[0]
    $use_server_name = $split_server_name[1]
  } else {
    $use_myid = $myid
    $use_server_name = $server_name
  }

  concat::fragment { "${group}_zookeeper_service_${name}":
    order   => "10-${group}-${use_server_name}",
    target  => "${homedir}/conf/zoo.cfg",
    content => template('zookeeper/zoonode.erb'),
  }

}
