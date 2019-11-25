# Simple class to manage set up of LiDAR
class lidar (
  String $lidarurl,
  Boolean $enable_reports = true,
  Boolean $manage_routes = true,
  String $facts_terminus = 'puppetdb',
  String $facts_cache_terminus = 'lidar',
  String $reports = 'puppetdb,lidar',
  Optional[String] $pe_console = undef,
) {

  if $enable_reports {
    pe_ini_setting {'enable lidar':
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
    pe_ini_setting {'enable lidar_routes.yaml':
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
