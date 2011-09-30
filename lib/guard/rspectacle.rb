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
    # @return [Boolean] when the start was successful
    #
    def start
      ENV['RAILS_ENV'] = 'test'

      if File.exists?('config/application.rb')
        Formatter.info 'Load Rails...'
        require 'config/application'
      end

      Formatter.info 'Load RSpec...'
      require 'spec/spec_helper'

      Formatter.info 'RSpectacle is ready!'
      true
    end

    # Gets called when the Guard should reload itself.
    #
    # @return [Boolean] when the reload was successful
    #
    def reload
      Dir.glob('**/*').each { |file| reload_file(file) }

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
      paths.each { |path| reload_file(path) }
      Runner.run(Inspector.clean(paths), options)
    end

    private

    # Reloads the given file.
    #
    # @param [String] file the changed file
    #
    def reload_file(file)
      return unless file =~ /\.rb$/

      Formatter.info "Reload #{ file }"
      load file

    rescue Exception => e
      Formatter.error "Error reloading file #{ file }: #{ e.message }"
    end

  end
end
