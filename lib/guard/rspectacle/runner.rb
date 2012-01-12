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
        # @param [Hash] options the options
        # @option options [String] :cli the RSpec CLI options
        # @option options [Boolean] :notification show notifications
        # @option options [Boolean] :hide_success hide success message notification
        # @param [IO] err the error stream
        # @param [IO] out the output stream
        # @return [Boolean] true if specs passed, false if failed
        #
        def run(files, options, err=$stderr, out=$stdout)
          rspec_options = files | options[:cli].to_s.split
          status = ::RSpec::Core::Runner.run(rspec_options, err, out)

          passed = status == 0

          # TODO: Get failed specs
          failed_specs = []

          if passed
            ::Guard::RSpectacle::Formatter.notify(::Guard::RSpectacle::Humanity.success, :image => :success) if options[:notification] && !options[:hide_success]
          else
            ::Guard::RSpectacle::Formatter.notify(::Guard::RSpectacle::Humanity.failure, :image => :failed) if options[:notification]
          end

          [passed, failed_specs]
        end
      end

    end
  end
end
