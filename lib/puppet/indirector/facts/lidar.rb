require 'puppet/indirector/facts/yaml'
require 'puppet/util/profiler'
require 'puppet/util/lidar'
require 'json'
require 'time'

# Lidar Facts
class Puppet::Node::Facts::Lidar < Puppet::Node::Facts::Yaml
  desc 'Save facts to LiDAR and then to yamlcache.'

  include Puppet::Util::Lidar

  def profile(message, metric_id, &block)
    message = 'LiDAR: ' + message
    arity = Puppet::Util::Profiler.method(:profile).arity
    case arity
    when 1
      Puppet::Util::Profiler.profile(message, &block)
    when 2, -2
      Puppet::Util::Profiler.profile(message, metric_id, &block)
    end
  end

  def save(request)
    # yaml cache goes first
    super(request)

    profile('lidar_facts#save', [:lidar, :facts, :save, request.key]) do
      begin
        Puppet.info 'Submitting facts to LiDAR'
        current_time = Time.now
        send_facts(request, current_time.clone.utc)
      rescue StandardError => e
        Puppet.err "Could not send facts to LiDAR: #{e}\n#{e.backtrace}"
      end
    end
  end
end
