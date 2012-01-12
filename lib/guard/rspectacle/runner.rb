# coding: utf-8

require 'rspec/core/runner'

module Guard
  class RSpectacle

    # The RSpectacle runner handles the execution of the rspec test.
    #
    module Runner

      class << self

        # Run a suite of RSpec examples.
        #
        # For reference, see:
        # - https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/runner.rb
        # - https://github.com/rspec/rspec-core/blob/master/spec/rspec/core/configuration_options_spec.rb
        #
        # @param [Array<String>] files the specs to run
        # @param [Array<String>] cli the RSpec command-line arguments
        # @param [IO] err the error stream
        # @param [IO] out the output stream
        # @return [Boolean] true if specs passed, false if failed
        #
        def run(files, cli, err=$stderr, out=$stdout)
          options = files | cli.to_s.split
          status = ::RSpec::Core::Runner.run(options, err, out)

          status == 0
        end
      end

    end
  end
end
