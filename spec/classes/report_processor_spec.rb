require 'spec_helper'

describe 'lidar::report_processor' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) { "service { 'pe-puppetserver': }" }

      # rubocop:disable Metrics/LineLength
      context 'with a lidar_url string value' do
        let(:params) do
          {
            'lidar_url' => 'https://lidar.example.com/in',
            'pe_console' => 'pe-console.example.com',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/lidar.yaml').with_content(%r{^# managed by puppet lidar module\n---\n'lidar_urls':\n  - 'https://lidar.example.com/in'\n'pe_console': 'pe-console.example.com'\n$}) }
      end

      context 'with a lidar_url array value' do
        let(:params) do
          {
            'lidar_url' => [
              'https://lidar-prod.example.com/in',
              'https://lidar-stage.example.com/in',
            ],
            'pe_console' => 'pe-console.example.com',
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_file('/etc/puppetlabs/puppet/lidar.yaml').with_content(%r{^# managed by puppet lidar module\n---\n'lidar_urls':\n  - 'https://lidar-prod.example.com/in'\n  - 'https://lidar-stage.example.com/in'\n'pe_console': 'pe-console.example.com'\n$}) }
      end
      # rubocop:enable Metrics/LineLength
    end
  end
end
