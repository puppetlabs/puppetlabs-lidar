# Simple class to enable the LiDAR report processor
#
# @summary Simple class to enable the LiDAR report processor
#
# @param [Stdlib::HTTPUrl] lidar_url
#   The url to send reports to.
#
# @param [Boolean] enable_reports
#   Enable sending reports to LiDAR
#
# @param [Boolean] manage_routes
#   Enable managing the LiDAR routes file
#
# @param [String[1]] facts_terminus
#
# @param [String[1]] facts_cache_terminus
#
# @param [String[1]] reports
#   A string containg the list of report processors to enable
#
# @param [Optional[Stdlib::Fqdn]] pe_console
#   The FQDN of your PE Console.
#
# @example Configuration via Hiera with default port
#   ---
#   lidar::report_processor::lidar_url: 'https://lidar.example.com/in'
#   lidar::report_processor::pe_console: 'pe-console.example.com'
#
# @example Configuration via Hiera with custom port
#   ---
#   lidar::report_processor::lidar_url: 'https://lidar.example.com:8443/in'
#   lidar::report_processor::pe_console: 'pe-console.example.com'
#
# @example Configuration in a manifest with default port
#   # Settings applied to both a master and compilers
#   class { 'profile::masters_and_compilers':
#     class { 'lidar::report_processor':
#       lidar_url  => 'https://lidar.example.com/in',
#       pe_console => 'pe-console.example.com',
#     }
#   }
#
# @example Configuration in a manifest with custom port
#   # Settings applied to both a master and compilers
#   class { 'profile::masters_and_compilers':
#     class { 'lidar::report_processor':
#       lidar_url  => 'https://lidar.example.com:8443/in',
#       pe_console => 'pe-console.example.com',
#     }
#   }
class lidar::report_processor (
  Stdlib::HTTPUrl $lidar_url,
  Boolean $enable_reports = true,
  Boolean $manage_routes = true,
  String[1] $facts_terminus = 'puppetdb',
  String[1] $facts_cache_terminus = 'lidar',
  String[1] $reports = 'puppetdb,lidar',
  Optional[Stdlib::Fqdn] $pe_console = undef,
) {

  if $enable_reports {
    ini_setting { 'enable lidar':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'reports',
      value   => $reports,
      notify  => Service['pe-puppetserver'],
    }
  }

  if $manage_routes {
    file { '/etc/puppetlabs/puppet/lidar_routes.yaml':
      ensure  => file,
      owner   => pe-puppet,
      group   => pe-puppet,
      mode    => '0640',
      content => epp('lidar/lidar_routes.yaml.epp'),
      notify  => Service['pe-puppetserver'],
    }
    ini_setting { 'enable lidar_routes.yaml':
      ensure  => present,
      path    => '/etc/puppetlabs/puppet/puppet.conf',
      section => 'master',
      setting => 'route_file',
      value   => '/etc/puppetlabs/puppet/lidar_routes.yaml',
      require => File['/etc/puppetlabs/puppet/lidar_routes.yaml'],
      notify  => Service['pe-puppetserver'],
    }
  }

  file { '/etc/puppetlabs/puppet/lidar.yaml':
    ensure  => file,
    owner   => pe-puppet,
    group   => pe-puppet,
    mode    => '0640',
    content => epp('lidar/lidar.yaml.epp'),
    notify  => Service['pe-puppetserver'],
  }
}
