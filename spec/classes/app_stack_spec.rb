require 'spec_helper'

describe 'lidar::app_stack' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile }
        it { is_expected.to  contain_group('docker').with_ensure('present') }
        it { is_expected.to  contain_class('docker').with_log_driver('journald') }
        it { is_expected.to  contain_class('docker::compose').with_ensure('present') }
        it { is_expected.to  contain_file('/opt/puppetlabs/lidar').with_ensure('directory') }
        it { is_expected.to  contain_file('/opt/puppetlabs/lidar/backup').with_ensure('directory') }
        it { is_expected.to  contain_file('/opt/puppetlabs/lidar/docker-compose.yaml').with_content(%r{lidar\/ingest-queue:latest"$}) }
        it { is_expected.to  contain_docker_compose('lidar').with_compose_files(['/opt/puppetlabs/lidar/docker-compose.yaml']) }
      end
    end
  end
end
