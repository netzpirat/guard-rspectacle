# coding: utf-8

module Guard
  class RSpectacular

    # The RSpectacular runner handles the execution of the rspec test.
    #
    module Runner
      class << self

        # Run the supplied specs.
        #
        # @param [Array<String>] paths the spec files or directories
        # @param [Hash] options the options for the Guard
        #
        def run(paths, options = { })
        end

      end
    end
  end
end
