
require 'spec_helper_acceptance'

describe 'Verify the minimum install' do
  before(:all) do
    set_sitepp_content(declare('class', 'common_events', { 'pe_token' => auth_token }.merge(cron_schedule)))
    trigger_puppet_run(:server)
  end

  after(:all) do
    set_sitepp_content(declare('class', 'common_events', { 'pe_token' => auth_token, 'disabled' => true }))
    trigger_puppet_run(:server)
  end

  describe 'places files correctly' do
    it 'api class folder' do
      directory = "#{CONFDIR}/common_events/api"
      expect(directory_exists?(directory)).to be true
    end

    it 'util class folder' do
      directory = "#{CONFDIR}/common_events/util"
      expect(directory_exists?(directory)).to be true
    end

    it 'events_collection.yaml' do
      yaml_file = "#{CONFDIR}/common_events/events_collection.yaml"
      expect(file_exists?(yaml_file)).to be true
    end

    it 'collect_api_events.rb' do
      script_file = "#{CONFDIR}/common_events/collect_api_events.rb"
      expect(file_exists?(script_file)).to be true
    end
  end

  describe 'configures cron' do
    it 'enables cron' do
      result =run_shell('crontab -l', targets: :server, expect_failures: true).stdout
      expect(result.include?('collect_api_events.rb')).to be true
    end

    it 'applies the correct schedule' do
      result = run_shell('crontab -l', targets: :server, expect_failures: true).stdout
      expect(result.include?('10 9 6 7 3')).to be true
    end
  end
end
