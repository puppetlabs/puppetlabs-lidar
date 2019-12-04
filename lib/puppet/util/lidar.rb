require 'puppet'
require 'puppet/util'
require 'puppet/node/facts'
require 'puppet/network/http_pool'
require 'fileutils'
require 'net/http'
require 'net/https'
require 'uri'
require 'yaml'
require 'json'
require 'time'

# rubocop:disable Style/ClassAndModuleCamelCase
# splunk_hec.rb
module Puppet::Util::Lidar

  def settings
    return @settings if @settings
    @settings_file = Puppet[:confdir] + '/lidar.yaml'
    @settings = YAML.load_file(@settings_file)
  end

  def pe_console
    settings['pe_console'] || Puppet[:certname]
  end

  def get_trusted_info(node)
    trusted = Puppet.lookup(:trusted_information) do
      Puppet::Context::TrustedInformation.local(node)
    end
    trusted.to_h
  end

  def send_to_lidar(url, payload)
    Puppet.info "Submitting data to LiDAR at #{url}"

    uri = URI.parse(url)

    headers = { "Content-Type" => "application/json" }

    # Create the HTTP objects
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.read_timeout = 5
    https.open_timeout = 5
    https.ssl_timeout = 5
    # After POC, we will properly integrate with Puppets CA
    # and use Puppet::Network::HttpPool.connection library
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = payload.to_json
    # Send the request
    response = https.request(request)
    unless response.kind_of?(Net::HTTPSuccess)
      Puppet.err _("LiDAR unable to submit data to %{uri} [%{code}] %{message}") % { uri: uri.path, code: response.code, message: response.msg }
    end
  end

  def send_facts(request, time)
    lidar_facts_url = settings['lidarurl'] + "/facts"
    lidar_packages_url = settings['lidarurl'] + "/packages"

    # Copied from the puppetdb fact indirector.  Explicitly strips
    # out the packages custom fact '_puppet_inventory_1'
    facts = request.instance.dup
    facts.values = facts.values.dup
    facts.values[:trusted] = get_trusted_info(request.node)

    inventory = facts.values['_puppet_inventory_1']
    package_inventory = inventory['packages'] if inventory.respond_to?(:keys)
    facts.values.delete('_puppet_inventory_1')

    console = pe_console

    request_body = {
      "key" => request.key,
      "transaction_uuid" => request.options[:transaction_uuid],
      "payload" => {
        "certname" => facts.name,
        "values" => facts.values,
        "environment" => request.options[:environment] || request.environment.to_s,
        "producer_timestamp" => Puppet::Util::Puppetdb.to_wire_time(time),
        "producer" => Puppet[:node_name_value],
        "pe_console" => console
      },
      "time" => time,
    }

    # Puppet.info "***LiDAR facts #{request_body.to_json}"

    send_to_lidar(lidar_facts_url, request_body)

    if package_inventory
      package_request = {
        "key" => request.key,
        "transaction_uuid" => request.options[:transaction_uuid],
        "packages" => package_inventory,
        "producer" => Puppet[:node_name_value],
        "pe_console" => console,
        "time" => time,
      }

      #Puppet.info "***LiDAR packages #{package_request.to_json}"

      send_to_lidar(lidar_packages_url, package_request)
    end
  end

end
