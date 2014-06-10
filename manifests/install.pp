# == Class: zookeeper::install
#
# Install class for zookeeper. Takes care of package installation, etc.
#
# === Parameters
#
# [*mirror*]
#   The location to download the installer from.
# [*version*]
#   The version of zookeeper to install.
# [*homedir*]
#   Install location for the final zookeeper package.
# [*datadir*]
#   Where to store/configure the zookeeper data.
# [*logdir*]
#   Storage location for zookeeper logs.
#
# === Examples
#
#  class { 'zookeeper::install':
#    mirror => 'http://www.mymirror.com/zookeeper-package',
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
class zookeeper::install (
  $mirror      = $zookeeper::params::zookeeper_mirror,
  $version     = $zookeeper::params::zookeeper_version,
  $manage_java = $zookeeper::params::manage_java,
  $homedir     = $zookeeper::params::zookeeper_home,
  $datadir     = $zookeeper::params::zookeeper_datadir,
  $logdir      = $zookeeper::params::zookeeper_logdir,
) {

  if ($manage_java == true) {
    #Install java package
    package { $zookeeper::params::java_package: }
    $install_require = [ File[$homedir], Package[$zookeeper::params::java_package] ]
  } else {
    $install_require = [ File[$homedir] ]
  }

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
    command => "rsync -auzp --exclude=\"src\" /var/tmp/zookeeper-${version}/ ${homedir}",
    creates => "${homedir}/zookeeper-${version}.jar",
    path    => ['/usr/bin', '/usr/sbin', '/sbin', 'bin'],
#    notify  => Service['zookeeper'],
    require => $install_require,
  }

}
