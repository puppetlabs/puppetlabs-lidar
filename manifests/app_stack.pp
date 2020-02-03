# @summary Configure a node to run LiDAR
#
# This class takes care of configuring a node to run LiDAR.
#
# @param [Boolean] analytics
#   Enable/Disable collection of Analytic Data
#
# @param [Boolean] create_docker_group
#   Ensure the docker group is present.
#
# @param [Boolean] manage_docker
#   Install and manage docker as part of app_stack
#
# @param [Integer] https_port
#   Secure port number to access the LiDAR UI
#
# @param [String[1]] compose_version
#   The version of docker-compose to install
#
# @param [String[1]] image_prefix
#   The string that comes before the name of each
#   container. This can be changed to support private
#   image repositories such as for internal testing or
#   air gapped environments.
#
# @param [String[1]] lidar_version
#   The version of the LiDAR containers to use
#
# @param [String[1]] log_driver
#   The log driver Docker will use
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
  Boolean $manage_docker = true,
  Integer $https_port = 443,
  String[1] $compose_version = '1.25.0',
  String[1] $image_prefix = 'puppet/lidar-',
  String[1] $lidar_version = '1.0.0-alpha.2',
  String[1] $log_driver = 'journald',
  Optional[Array[String[1]]] $docker_users = undef,
){
  if $create_docker_group {
    ensure_resource('group', 'docker', {'ensure' => 'present' })
  }

  if $manage_docker {

    class { 'docker':
      docker_users => $docker_users,
      log_driver   => $log_driver,
    }

    class { 'docker::compose':
      ensure  => present,
      version => $compose_version,
    }

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
        'image_prefix'  => $image_prefix,
        'lidar_version' => $lidar_version,
        'https_port'    => $https_port,
        'analytics'     => $analytics,
      }),
    ;
  }

  docker_compose { 'lidar':
    ensure        => present,
    compose_files => [ '/opt/puppetlabs/lidar/docker-compose.yaml', ],
  }
}
