#!/opt/puppetlabs/puppet/bin/ruby
require 'find'
require 'yaml'

def require_classes(modulepaths)
  catch :done do
    modulepaths.split(':').each do |modulepath|
      Find.find(modulepath) do |path|
        if path =~ %r{common_events_library.gemspec}
          $LOAD_PATH.unshift("#{File.dirname(path)}/lib")
          throw :done
        end
      end
    end
  end

  require 'events_collection/lockfile'
  require 'events_collection/orchestrator_event'
  require 'common_events_library'
end

def main(confdir, modulepaths, statedir)

  require_classes(modulepaths)

  begin
    lockfile = CommonEvents::Lockfile.new(statedir)
    settings = YAML.safe_load(File.read("#{confdir}/events_collection.yaml"))
    unless lockfile.already_running?
      lockfile.write_lockfile
      require 'pry'; binding.pry;
      orchestrator_client = Orchestrator.new('localhost', username: settings['pe_username'], password: settings['pe_password'], token: settings['pe_token'], ssl_verify: false)
      puts orchestrator_client.get_jobs(limit: 1)
      # Find any compatible reports
      # Reports should be in /lib/reports/common_events
    else
      puts 'already running'
    end
  rescue => exception
    puts exception
  ensure
    lockfile.remove_lockfile
  end
end

if $PROGRAM_NAME == __FILE__
  confdir     = ARGV[0]
  modulepaths = ARGV[1]
  statedir    = ARGV[2]
  main(confdir, modulepaths, statedir)
end
