class zookeeper::config (
  $homedir    = $zookeeper::params::zookeeper_home,
  $datadir    = $zookeeper::params::zookeeper_datadir,
  $logdir     = $zookeeper::params::zookeeper_logdir,
  $clientport = $zookeeper::params::zookeeper_clientport,
  $group      = 'default',
  $myid       = fqdn_rand(50),
) {

  #Add concat setup just in case
  include concat::setup

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

  #Collect exported servers and realize to the zookeeper config file
  Zookeeper::Servernode <<| group == $group |>>

}
