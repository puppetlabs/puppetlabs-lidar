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

    url = URI.parse(lidar_url)
    headers = { "Content-Type" => "application/json" }
    # This metric_id option is silently ignored by Puppet's http client
    # (Puppet::Network::HTTP) but is used by Puppet Server's http client
    # (Puppet::Server::HttpClient) to track metrics on the request made to the
    # `reporturl` to store a report.
    options = { :metric_id => [:puppet, :report, :lidar] }
    if url.user && url.password
      options[:basic_auth] = {
        :user => url.user,
        :password => url.password
      }
    end
    use_ssl = url.scheme == 'https'
    ssl_context = use_ssl ? Puppet.lookup(:ssl_context) : nil
    conn = Puppet::Network::HttpPool.connection(url.host, url.port, use_ssl: use_ssl, ssl_context: ssl_context)

    # Add in pe_console & producer fields
    report_payload = JSON.parse(self.to_json)
    report_payload['pe_console'] = pe_console
    report_payload['producer'] = Puppet[:certname]

    response = conn.post(url.path, report_payload.to_json, headers, options)
    unless response.kind_of?(Net::HTTPSuccess)
      Puppet.err _("LiDAR unable to submit report to %{url} [%{code}] %{message}") % { url: url.path, code: response.code, message: response.msg }
    end
  end
end
