require 'json'

module CommonEvents
  class Lockfile
    attr_accessor :filepath

    def initialize(basepath)
      @filepath = "#{basepath}/events_collection_run.lock"
    end

    def existing_file?
      File.exist? filepath
    end

    def info
      if existing_file?
        JSON.parse(File.read(filepath))
      else
        {pid: nil, program_name: ''}
      end
    end

    def write_lockfile
      body = {
        pid:          Process.pid,
        program_name: $PROGRAM_NAME,
      }

      File.write(filepath, body.to_json)
    end

    def remove_lockfile
      File.delete(filepath) if existing_file?
    end

    def already_running?
      pid = self.info['pid']
      pid.nil? ? false : validate_command(pid)
    end

    def validate_command(pid)
      begin
        command = File.read("/proc/#{pid}/cmdline")
        !!info['program_name'].match(%r{#{$command}})
      rescue => exception
        false
      end
    end
  end
end