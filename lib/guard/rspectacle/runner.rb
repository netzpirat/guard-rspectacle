# coding: utf-8

require 'rspec/core/runner'

module Guard
  class RSpectacle

    autoload :Formatter, 'guard/rspectacle/formatter'

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

          RSpec::Core::Runner.run(paths)

        rescue Exception => e
          Formatter.error "Error while spec run: #{ e.message }"
        end

      end
    end
  end
end
