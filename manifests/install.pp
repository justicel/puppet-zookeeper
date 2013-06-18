class zookeeper::install (
  $mirror  = $zookeeper::params::zookeeper_mirror,
  $version = $zookeeper::params::zookeeper_version,
  $home    = $zookeeper::params::zookeeper_home,
  $datadir = $zookeeper::params::zookeeper_datadir,
) {

  #Download and extract the zookeeper archive
  exec { 'zookeeper-get':
    command => "wget ${mirror}/zookeeper-${version}/zookeeper-${version}.tar.gz \
-O /var/tmp/zookeeper-${version}.tar.gz",
    creates => "/var/tmp/zookeeper-${version}.tar.gz",
    path    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
    cwd     => '/var/tmp',
    notify  => Exec['zookeeper-extract'],
  }

  #Install zookeeper
  exec { 'zookeeper-extract':
    command => "tar -C /var/tmp -xzf /var/tmp/zookeeper-${version}.tar.gz",
    creates => "/var/tmp/zookeeper-${version}",
    path    => ['/usr/bin', '/usr/sbin', '/sbin', '/bin'],
    notify  => Exec['zookeeper-install'],
  }
  exec { 'zookeeper-install':
    command => "rsync -auzp --exclude=\"src\" /var/tmp/zookeeper-${version}/ ${home}",
    creates => "${home}/zookeeper-${version}.jar",
    path    => ['/usr/bin', '/usr/sbin', '/sbin', 'bin'],
#    notify  => Service['zookeeper'],
    require => File[$home],
  }

}
