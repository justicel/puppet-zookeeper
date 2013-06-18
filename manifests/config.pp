class zookeeper::config (
  $home       = $zookeeper::params::zookeeper_home,
  $datadir    = $zookeeper::params::zookeeper_datadir,
  $clientport = $zookeeper::params::zookeeper_clientport,
  $group      = 'default',
) {

  #Add concat setup just in case
  include concat::setup

  #File definition for the home folder for zookeeper
  file { $home:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  #Zookeeper datadir
  file { $datadir:
    ensure   => directory,
    owner    => 'root',
    group    => 'root',
    requires => File[$home],
  }

  #Define zookeeper config file for cluster
  concat { "${home}/conf/zoo.cfg":
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Exec['zookeeper-install'],
  }
  concat::fragment { '00_zookeeper_header':
    target  => "${home}/conf/zoo.cfg":
    order   => '01',
    content => template('zookeeper/zoo.cfg.header.erb'),
  }

  #Collect exported servers and realize to the zookeeper config file
  Zookeeper::Servernode <<| group == $group |>>


}
