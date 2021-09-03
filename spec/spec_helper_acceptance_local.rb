require 'serverspec'
require 'puppet_litmus'
require 'support/acceptance/helpers.rb'

include PuppetLitmus
PuppetLitmus.configure!

CONFDIR = '/etc/puppetlabs/puppet'.freeze
LOGDIR  = '/var/log/puppetlabs/common_events'.freeze
LOCKFILEDIR = '/opt/puppetlabs/common_events/cache/state'.freeze

RSpec.configure do |config|
  include TargetHelpers

  config.before(:suite) do
    # Stop the puppet service on the puppetserver to avoid edge-case conflicting
    # Puppet runs (one triggered by service vs one we trigger)
    run_shell('puppet resource service puppet ensure=stopped', targets: :server)
    acceptance_setup
  end
end

def acceptance_setup
  set_sitepp_content(declare('class', 'common_events', { 'pe_token' => auth_token, 'disabled' => true }))
  trigger_puppet_run(:server)
end

def console_host_fqdn
  @console_host_fqdn ||= run_shell('hostname -A', targets: :server).stdout.strip
end

def auth_token
  @auth_token ||= run_shell('puppet access show', targets: :server).stdout.chomp
end

# TODO: This will cause some problems if we run the tests
# in parallel. For example, what happens if two targets
# try to modify site.pp at the same time?
def set_sitepp_content(manifest)
  content = <<-HERE
  node default {
    #{manifest}
  }
  HERE

  write_file(content, '/etc/puppetlabs/code/environments/production/manifests/site.pp', targets: :server)
  run_shell('chown pe-puppet:pe-puppet /etc/puppetlabs/code/environments/production/manifests/site.pp', targets: :server)
end

def trigger_puppet_run(target, acceptable_exit_codes: [0, 2])
  result = run_shell('puppet agent -t --detailed-exitcodes', targets: :server, expect_failures: true)
  unless acceptable_exit_codes.include?(result[:exit_code])
    raise "Puppet run failed\nstdout: #{result[:stdout]}\nstderr: #{result[:stderr]}"
  end
  result
end

def declare(type, title, params = {})
  params = params.map do |name, value|
    value = "'#{value}'" if value.is_a?(String)
    "  #{name} => #{value},"
  end

  <<-HERE
  #{type} { '#{title}':
  #{params.join("\n")}
  }
  HERE
end

def to_manifest(*declarations)
  declarations.join("\n")
end

def setup_manifest(pe_token, cron_disabled: true)
  <<-MANIFEST
  class { 'common_events':
    pe_token => '#{pe_token}',
    disabled => '#{cron_disabled}',
  }
  MANIFEST
end

def cron_schedule
  {
    cron_minute:   '10',
    cron_hour:     '9',
    cron_weekday:  '3',
    cron_month:    '7',
    cron_monthday: '6',
  }
end

def file_exists?(file_path, opts = {})
  command = "test -f #{file_path} && echo 'true'"
  result = run_shell(command, opts.merge(expect_failures: true)).stdout
  result.include?('true')
end

def directory_exists?(file_path, opts = {})
  command = "test -d #{file_path} && echo 'true'"
  result = run_shell(command, opts.merge(expect_failures: true)).stdout
  result.include?('true')
end
