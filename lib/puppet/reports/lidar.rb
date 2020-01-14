require 'puppet'
require 'puppet/network/http_pool'
require 'puppet/util/lidar'
require 'uri'
require 'json'

Puppet::Reports.register_report(:lidar) do
  desc <<-DESC
    A copy of the standard http report processor except it sends a
    `application/json` payload to `:lidar_url`
  DESC

  include Puppet::Util::Lidar

  def process
    # Add in pe_console & producer fields
    report_payload = JSON.parse(to_json)
    report_payload['pe_console'] = pe_console
    report_payload['producer'] = Puppet[:certname]

    lidar_urls = settings['lidar_urls']

    lidar_urls.each do |url|
      lidar_url = "#{url}/data"
      Puppet.info "LiDAR sending report to #{lidar_url}"
      send_to_lidar(lidar_url, report_payload)
    end
  end
end
