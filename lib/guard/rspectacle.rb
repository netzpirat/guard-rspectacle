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
    autoload :Notifier, 'guard/rspectacle/notifier'

    attr_accessor :last_run_passed, :rerun_examples

    DEFAULT_OPTIONS = {
        :cli => '',
        :notification   => true,
        :hide_success   => false,
        :all_on_start   => true,
        :keep_failed    => true,
        :keep_pending   => true,
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
    # @option options [Boolean] :keep_failed keep failed examples and add them to the next run again
    # @option options [Boolean] :keep_pending keep pending examples and add them to the next run again
    # @option options [Boolean] :all_after_pass run all specs after all examples have passed again after failing
    #
    def initialize(watchers = [], options = {})
      options = DEFAULT_OPTIONS.merge(options)

      super(watchers, options)

      self.last_run_passed = true
      self.rerun_examples = []
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

      self.last_run_passed = true
      self.rerun_examples = []
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_all
      passed, failed_examples, passed_examples, pending_examples = Runner.run(['spec'], options.merge({ :message => 'Run all specs'}))

      if options[:keep_pending]
        self.rerun_examples = failed_examples + pending_examples
      else
        self.rerun_examples = failed_examples
      end

      self.last_run_passed = passed

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

      specs += self.rerun_examples if options[:keep_failed]

      # RSpec reloads the files, so reload only non spec files
      (paths - specs).each { |path| Reloader.reload_file(path) }

      passed, failed_examples, passed_examples, pending_examples = Runner.run(specs, options)

      if options[:keep_pending]
        self.rerun_examples += failed_examples + pending_examples
      else
        self.rerun_examples += failed_examples
      end

      self.rerun_examples -= passed_examples

      run_all if passed && !self.last_run_passed && options[:all_after_pass]
      self.last_run_passed = passed

      throw :task_has_failed unless passed
    end

  end
end
