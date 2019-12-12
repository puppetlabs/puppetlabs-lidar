# @summary Configure a node to run LiDAR
#
# This class takes care of configuring a node to run LiDAR.
#
# @param [Boolean] create_docker_group
#   Ensure the docker group is present.
#
# @param [String[1]] log_driver
#   The log driver Docker will use
#
# @param [String[1]] compose_version
#   The version of docker-compose to install
#
# @param [String[1]] lidar_version
#   The version of the LiDAR containers to use
#
# @param [Boolean] analytics
#   Enable/Disable collection of Analytic Data
#
# @param [Integer] port
#   Port number to access the LiDAR UI
#
# @param [Optional[Array[String[1]]]] docker_users
#   Users to be added to the docker group on the system
#
# @example Use defalts or configure via Hiera
#   include lidar::app_stack
#
# @example Manage the docker group elsewhere
#   realize(Group['docker'])
#
#   class { 'lidar::app_stack':
#     create_docker_group => false,
#     require             => Group['docker'],
#   }
#
class lidar::app_stack (
  Boolean $analytics = true,
  Boolean $create_docker_group = true,
  String[1] $log_driver = 'journald',
  String[1] $compose_version = '1.25.0',
  String[1] $lidar_version = 'latest',
  Integer $port = 443,
  Optional[Array[String[1]]] $docker_users = undef,
){
  if $create_docker_group {
    ensure_resource('group', 'docker', {'ensure' => 'present' })
  }

  class { 'docker':
    docker_users => $docker_users,
    log_driver   => $log_driver,
  }

  class { 'docker::compose':
    ensure  => present,
    version => $compose_version,
  }

  file {
    default:
      owner   => 'root',
      group   => 'docker',
      require => Group['docker'],
      before  => Docker_compose['lidar'],
    ;
    '/opt/puppetlabs/lidar':
      ensure => directory,
      mode   => '0775',
    ;
    '/opt/puppetlabs/lidar/backup':
      ensure => directory,
      mode   => '0775',
    ;
    '/opt/puppetlabs/lidar/docker-compose.yaml':
      ensure  => file,
      mode    => '0440',
      content => epp('lidar/docker-compose.yaml.epp', {
        'lidar_version' => $lidar_version,
        'port'          => $port,
        'analytics'     => $analytics,
      }),
    ;
  }

  docker_compose { 'lidar':
    ensure        => present,
    compose_files => [ '/opt/puppetlabs/lidar/docker-compose.yaml', ],
  }
}
