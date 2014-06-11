# == Class: zookeeper::install
#
# Install class for zookeeper. Takes care of package installation, etc.
#
# === Parameters
#
# [*install_method*]
#   Available Options - wget, deb
#   Specify the installation method. Defaults to a combination of wget/exec calls
#   to retrieve JARs from Zookeeper mirror.
#   If the deb method is specified, this will use a .deb package instead.
#   For deb, all paths are based on the output of "ant deb" run against Zookeeper sources.
# [*mirror*]
#   The location to download the installer from.
# [*version*]
#   The version of zookeeper to install.
#   If install_method = wget, format should be a version number. Example - 3.4.6
#   If install_method = deb, format should be a debian package version number.
# [*manage_java*]
#   Boolean, which determines if this module depends on the Java package being installed.
#   Defaults to true.
# [*homedir*]
#   Only applicable if install_method = wget.
#   Install location for the final zookeeper package.
# [*datadir*]
#   Where to store/configure the zookeeper data.
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
# Nathan Sullivan <nathan@nightsys.net>
#
# === Copyright
#
# Copyright 2013 Justice London, unless otherwise noted.
#
class zookeeper::install (
  $install_method = $zookeeper::params::install_method,
  $mirror         = $zookeeper::params::zookeeper_mirror,
  $version        = $zookeeper::params::zookeeper_version,
  $manage_java    = $zookeeper::params::manage_java,
  $homedir        = undef,
  $datadir        = undef,
) {
  case $install_method {
    'wget': {
      # Set some sane defaults for homedir/datadir/logdir.
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
      #Determine if we manage Java with this module.
      if ($manage_java == true) {
        #Install java package
        package { $zookeeper::params::java_package: }
        $install_require = [ File[$use_homedir], Package[$zookeeper::params::java_package] ]
      } else {
        $install_require = [ File[$use_homedir] ]
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
    'deb': {
      package {
        'zookeeper':
          ensure => $version
      }
    }
    default: {
      crit('Undefined or invalid input parameter install_method, cannot proceed')
    }
  }
}
