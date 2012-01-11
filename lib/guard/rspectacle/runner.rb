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

        # Run the supplied specs.
        #
        # @param [Array<String>] paths the spec files or directories
        # @param [Hash] options the options for the Guard
        #
        def run(paths, options = {})
          return false if paths.empty?

          Formatter.info "Run #{ paths.join('') }"

          # RSpec hardcore reset
          world = RSpec::Core::World.new
          configuration = RSpec::Core::Configuration.new

          RSpec.instance_variable_set :@world, world
          RSpec.instance_variable_set :@configuration, configuration

          #TODO: Add Formatter: configuration.add_formatter ::Guard::RSpectacle::Notifier

          RSpec::Core::CommandLine.new(RSpec::Core::ConfigurationOptions.new(paths), configuration, world).run($stderr, $stdout)

          #TODO: Get failed examples

        rescue Exception => e
          Formatter.error "Error while spec run: #{ e.message }\n#{e.backtrace.join("\n")}"
        end

      end
    end
  end
end
