require 'guard'
require 'guard/guard'
require 'guard/watcher'

module Guard

  # The RSpecRails guard that gets notifications about the following
  # Guard events: `start`, `stop`, `reload`, `run_all` and `run_on_change`.
  #
  class RSpectacle < Guard

    autoload :Formatter, 'guard/rspectacle/formatter'
    autoload :Inspector, 'guard/rspectacle/inspector'
    autoload :Runner, 'guard/rspectacle/runner'

    DEFAULT_OPTIONS = {
        :cli => ''
    }

    # Initialize Guard::RSpecRails.
    #
    # @param [Array<Guard::Watcher>] watchers the watchers in the Guard block
    # @param [Hash] options the options for the Guard
    #
    def initialize(watchers = [], options = { })
      options = DEFAULT_OPTIONS.merge(options)

      watchers << ::Guard::Watcher.new(%r{^.*$})

      super(watchers, options)
    end

    # Gets called once when Guard starts.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def start
      ENV['RAILS_ENV'] ||= 'test'
      Formatter.info "Starting RSpectacle #{ ENV['RAILS_ENV'] } environment"

      require './spec/spec_helper'

      Formatter.info 'RSpectacle is ready!'
      run_all
    end

    # Gets called when the Guard should reload itself.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def reload
      Dir.glob('**/*').each { |file| reload_file(file) }
    end

    # Gets called when all specs should be run.
    #
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_all
      passed = Runner.run(['spec'], cli)
      if passed
        Formatter.notify "How cool, all works!", :image => :success
      else
        Formatter.notify "Failing... not there yet.", :image => :failed
      end
    end

    # Gets called when watched paths and files have changes.
    #
    # @param [Array<String>] paths the changed paths and files
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def run_on_change(paths)
      clean_paths = Inspector.clean(paths)
      paths.each { |path| reload_file(path) }
      return unless clean_paths.any?# TODO: Maybe bug in guard: watches files not actualy matching, like stuff in db/
      passed = Runner.run(clean_paths, cli)
      if passed
        Formatter.notify "Well done! Specs passed!", :image => :success
      else
        Formatter.notify "Try harder, still failing.", :image => :failed
      end
    end

    private

    # Reloads the given file.
    #
    # @param [String] file the changed file
    # @raise [:task_has_failed] when run_on_change has failed
    #
    def reload_file(file)
      return unless file =~ /\.rb$/

      Formatter.info "Reload #{ file }"
      load file

    rescue Exception => e
      Formatter.error "Error reloading file #{ file }: #{ e.message }"

      throw :task_has_failed
    end

    def cli
      options[:cli] || ''
    end

  end
end
