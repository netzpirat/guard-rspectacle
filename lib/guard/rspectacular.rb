require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard

  # The RSpectacular guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class RSpectacular < Guard

    autoload :Formatter, 'guard/rspectacular/formatter'
    autoload :Inspector, 'guard/rspectacular/inspector'
    autoload :Runner, 'guard/rspectacular/runner'

    DEFAULT_OPTIONS = {
    }

    # Initialize Guard::RSpectacular.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    #
    def initialize(watchers = [], options = { })
      options = DEFAULT_OPTIONS.merge(options)

      super(watchers, options)
    end

    # Gets called once when Guard starts.
    #
    # @return [Boolean] when the start was successful
    #
    def start
      true
    end

    # Gets called when the Guard should reload itself.
    #
    # @return [Boolean] when the reload was successful
    #
    def reload
      true
    end

    # Gets called when all specs should be run.
    #
    # @return [Boolean] when running all specs was successful
    #
    def run_all
      Runner.run(['spec'], options)
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @return [Boolean] when running the changed specs was successful
    #
    def run_on_change(paths)
      Runner.run(Inspector.clean(paths), options)
    end

  end
end
