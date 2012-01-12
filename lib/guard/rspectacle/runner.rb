# coding: utf-8

require 'guard/rspectacle/notifier'

require 'rspec/core/runner'
require 'rspec/core/command_line'
require 'rspec/core/world'
require 'rspec/core/configuration'
require 'rspec/core/configuration_options'

require 'stringio'

module Guard
  class RSpectacle

    # The RSpectacle runner handles the execution of the rspec test.
    #
    module Runner

      class << self
        # Run a suite of RSpec examples.
        #
        # #### Parameters
        # * +files+ - an array of files to run specs on
        # * +cli+ - an array of RSpec command-line-supported arguments
        # * +err+ - error stream (Default: $stderr)
        # * +out+ - output stream (Default: $stdout)
        #
        # #### Returns
        # * +Boolean+ - true if specs passed, false if failed
        def run(files, cli, err=$stderr, out=$stdout)
          @last_run_files ||= []
          files = @last_run_files if files.empty?
          # For reference, see:
          # - https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/runner.rb
          # - https://github.com/rspec/rspec-core/blob/master/spec/rspec/core/configuration_options_spec.rb
          rspec_options = files | cli.to_s.split() # merge files and the passed in options for RSpec
          code = ::RSpec::Core::Runner.run(rspec_options, err, out)

          @last_run_files = files
          code == 0
        end
      end

    end
  end
end
