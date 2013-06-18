# == Class: zookeeper
#
# Full description of class zookeeper here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { zookeeper:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class zookeeper (
  $version      = $zookeeper::params::zookeeper_version,
  $home         = $zookeeper::params::zookeeper_home,
  $datadir      = $zookeeper::params::zookeeper_datadir,
  $clientport   = $zookeeper::params::zookeeper_clientport,
  $server_name  = $::fqdn,
  $server_group = 'default',
) inherits zookeeper::params
{

  #Add node to cluster with stored config
  @@zookeeper::servernode { "${server_name}":
    group => $server_group,
    home  => $home,
  }

  #Download and install the zookeeper source
  class { 'zookeeper::install':
    version     => $version,
    home        => $home,
    datadir     => $datadir,
  }

  class { 'zookeeper::config':
    home       => $home,
    datadir    => $datadir,
    clientport => $clientport,
    group      => $server_group,
  }

}
