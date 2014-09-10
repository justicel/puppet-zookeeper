#Basic parameter options for zookeeper, including mirrors location etc.
class zookeeper::params {

  $install_method         = 'wget'
  $zookeeper_version      = '3.4.6'
  $zookeeper_mirror       = 'http://mirrors.sonic.net/apache/zookeeper'
  $zookeeper_wget_user    = 'root'
  $zookeeper_wget_home    = '/opt/zookeeper'
  $zookeeper_wget_datadir = "${zookeeper::params::zookeeper_wget_home}/data"
  $zookeeper_wget_logdir  = "${zookeeper::params::zookeeper_wget_home}/logs"
  $zookeeper_deb_user     = 'zookeeper'
  $zookeeper_deb_home     = '/var/lib/zookeeper'
  $zookeeper_deb_datadir  = "${zookeeper::params::zookeeper_deb_home}/data"
  $zookeeper_deb_logdir   = '/var/log/zookeeper'
  $zookeeper_clientport   = '2181'
  $manage_java            = true
  $manage_service         = true
  $server_list            = {}

  if ($manage_java == true) {
    case $::operatingsystem {
      'RedHat', 'CentOS': {
        $java_package = 'java-1.7.0-openjdk'
      }
      'Debian', 'Ubuntu': {
        $java_package = 'openjdk-7-jdk'
      }
      default: { }
    }
  }

}
