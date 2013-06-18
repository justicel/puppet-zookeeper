class zookeeper::params {

  $zookeeper_version    = '3.4.5'
  $zookeeper_mirror     = 'http://mirrors.sonic.net/apache/zookeeper'
  $zookeeper_home       = '/opt/zookeeper'
  $zookeeper_datadir    = "${zookeeper::params::zookeeper_home}/data"
  $zookeeper_clientport = '2181'

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
