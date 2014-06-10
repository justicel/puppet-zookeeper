#Basic parameter options for zookeeper, including mirrors location etc.
class zookeeper::params {

  $zookeeper_version    = '3.4.5'
  $zookeeper_mirror     = 'http://mirrors.sonic.net/apache/zookeeper'
  $zookeeper_home       = '/opt/zookeeper'
  $zookeeper_datadir    = "${zookeeper::params::zookeeper_home}/data"
  $zookeeper_logdir     = "${zookeeper::params::zookeeper_home}/logs"
  $zookeeper_clientport = '2181'
  $manage_java          = true
  $server_list          = []

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
