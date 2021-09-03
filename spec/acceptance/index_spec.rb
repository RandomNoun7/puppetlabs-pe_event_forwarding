require 'spec_helper_acceptance'
require 'yaml'

describe 'index file' do
  before(:all) do
    run_shell("#{CONFDIR}/common_events/collect_api_events.rb", targets: :server)
  end

  it 'index file exists' do
    expect(file_exists?("#{CONFDIR}/common_events/common_events_indexes.yaml", targets: :server)).to be true
  end

  it 'writes expected keys' do
    index_contents = run_shell("cat #{CONFDIR}/common_events/common_events_indexes.yaml", targets: :server).stdout
    index = YAML.safe_load(index_contents, [Symbol])
    [:classifier, :rbac, :'pe-console', :'code-manager', :orchestrator].each do |key|
      expect(index.keys.include?(key)).to be true
    end
  end

  it 'updates orchestrator index value' do
    index_contents = run_shell("cat #{CONFDIR}/common_events/common_events_indexes.yaml", targets: :server).stdout
    index          = YAML.safe_load(index_contents, [Symbol])
    current_value  = index[:orchestrator]
    run_shell("puppet task run facts --nodes #{console_host_fqdn}", targets: :server)
    index_contents = run_shell("#{CONFDIR}/common_events/collect_api_events.rb ; cat #{CONFDIR}/common_events/common_events_indexes.yaml", targets: :server).stdout
    index = YAML.safe_load(index_contents, [Symbol])
    updated_value = index[:orchestrator]
    expect(updated_value).to eql(current_value + 1)
  end
end
