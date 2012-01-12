require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard

  # The RSpecRails guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class RSpectacle < Guard

    autoload :Formatter, 'guard/rspectacle/formatter'
    autoload :Humanity, 'guard/rspectacle/humanity'
    autoload :Inspector, 'guard/rspectacle/inspector'
    autoload :Runner, 'guard/rspectacle/runner'
    autoload :Reloader, 'guard/rspectacle/reloader'

    attr_accessor :last_run_failed, :last_failed_paths

    DEFAULT_OPTIONS = {
        :cli => '',
        :notification   => true,
        :hide_success   => false,
        :all_on_start   => true,
        :keep_failed    => true,
        :all_after_pass => true,
    }

    # Initialize Guard::RSpecRails.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    # @option options [String] :cli the RSpec CLI options
    # @option options [Boolean] :notification show notifications
    # @option options [Boolean] :hide_success hide success message notification
    # @option options [Boolean] :all_on_start Run all specs on start
    # @option options [Boolean] :keep_failed keep failed suites and add them to the next run again
    # @option options [Boolean] :all_after_pass run all suites after a suite has passed again after failing
    #
    def initialize(watchers = [], options = {})
      options = DEFAULT_OPTIONS.merge(options)

      super(watchers, options)

      self.last_run_failed = false
      self.last_failed_paths = []
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def start
      ENV['RAILS_ENV'] ||= 'test'
      require './spec/spec_helper'

      Formatter.info "RSpectacle is ready in #{ ENV['RAILS_ENV'] } environment."
      run_all if options[:all_on_start]
    end

    # Gets called when the Guard should reload itself.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def reload
      Dir.glob('**/*.rb').each { |file| Reloader.reload_file(file) }

      self.last_run_failed = false
      self.last_failed_paths = []
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_all
      passed, failed_specs = Runner.run(['spec'], options)

      self.last_failed_paths = failed_specs
      self.last_run_failed = !passed

      throw :task_has_failed unless passed
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_change(paths)
      specs = Inspector.clean(paths)
      return false if specs.empty?

      specs += self.last_failed_paths if options[:keep_failed]

      # RSpec reloads the files, so reload only non spec files
      (paths - specs).each { |path| Reloader.reload_file(path) }

      passed, failed_specs = Runner.run(specs, options)

      if passed
        self.last_failed_paths = self.last_failed_paths - paths
        run_all if self.last_run_failed && options[:all_after_pass]
      else
        self.last_failed_paths = self.last_failed_paths + failed_specs
      end

      self.last_run_failed = !passed

      throw :task_has_failed unless passed
    end

  end
end
