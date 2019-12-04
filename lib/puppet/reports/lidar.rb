require 'puppet'
require 'puppet/network/http_pool'
require 'puppet/util/lidar'
require 'uri'
require 'json'

Puppet::Reports.register_report(:lidar) do

  desc <<-DESC
    A copy of the standard http report processor except it sends a
    `application/json` payload to `:lidarurl`
  DESC

  include Puppet::Util::Lidar

  def process
    lidar_url = settings['lidarurl'] + "/data"

    Puppet.info "LiDAR sending report to #{lidar_url}"

    # Add in pe_console & producer fields
    report_payload = JSON.parse(self.to_json)
    report_payload['pe_console'] = pe_console
    report_payload['producer'] = Puppet[:certname]

    send_to_lidar(lidar_url, report_payload)

  end
end
