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
        # @param [Array<String>] examples the specs to run
        # @param [Hash] options the options
        # @option options [String] :cli the RSpec CLI options
        # @option options [Boolean] :notification show notifications
        # @option options [Boolean] :hide_success hide success message notification
        # @param [IO] err the error stream
        # @param [IO] out the output stream
        # @return [Array] the spec result: status, failed_examples, passed_examples, pending_examples
        #
        def run(examples, options, err=$stderr, out=$stdout)
          message = options[:message] || "Run #{ examples.join(' ') }"
          ::Guard::UI.info(message, :reset => true)

          rspec_options = options[:cli].to_s.split
          rspec_options.delete('--drb')
          rspec_options.delete('-X')
          rspec_options += rspectacular_options + examples

          begin
            status = ::RSpec::Core::Runner.run(rspec_options, err, out)

            passed          = status == 0
            failed_examples = ::Guard::RSpectacle::Notifier.failed_examples || []
            passed_examples = ::Guard::RSpectacle::Notifier.passed_examples || []
            duration        = ::Guard::RSpectacle::Notifier.duration || 0.0
            example_count   = ::Guard::RSpectacle::Notifier.example_count || -1
            failure_count   = ::Guard::RSpectacle::Notifier.failure_count || -1
            pending_count   = ::Guard::RSpectacle::Notifier.pending_count || -1

            if options[:notification]

              message = " #{ example_count } example#{ example_count == 1 ? '' : 's' }"
              message << ", #{ failure_count } failure#{ failure_count == 1 ? '' : 's' }"
              message << " (#{ pending_count } pending)" if pending_count > 0
              message << "\nin #{ round(duration) } seconds"

              if failure_count > 0
                ::Guard::RSpectacle::Formatter.notify(::Guard::RSpectacle::Humanity.failure + message,
                                                      :title    => 'RSpec results',
                                                      :image    => :failed,
                                                      :priority => -2)
              elsif pending_count > 0
                ::Guard::RSpectacle::Formatter.notify(::Guard::RSpectacle::Humanity.pending + message,
                                                      :title    => 'RSpec results',
                                                      :image    => :pending,
                                                      :priority => -1)
              else
                ::Guard::RSpectacle::Formatter.notify(::Guard::RSpectacle::Humanity.success + message,
                                                      :title    => 'RSpec results',
                                                      :image    => :success,
                                                      :priority => 2) if !options[:hide_success]
              end
            end

            [passed, relative(failed_examples), relative(passed_examples)]

          rescue Exception => e
            ::Guard::RSpectacle::Formatter.error("Error running specs: #{ e.message }")

            [false, [], []]
          end
        end

        private

        # Make all the paths relative to the current working
        # directory (the project dir).
        #
        # @paramn [Array<String>] the absolute paths
        # @return [Array<String>] the relative paths
        #
        def relative(paths)
          paths.map { |path| path.gsub(Dir.pwd + '/', '') }
        end

        # Returns the RSpec options needed to run RSpectacular.
        #
        # @return [Array<String>] the cli options
        #
        def rspectacular_options
          options = []

          options << '--require'
          options << "#{ File.dirname(__FILE__) }/notifier.rb"
          options << '--format'
          options << 'Guard::RSpectacle::Notifier'
          options << '--out'
          options << null_device

          options
        end

        # Returns a null device for all OS.
        #
        # @return [String] the name of the null device
        #
        def null_device
          RUBY_PLATFORM.index('mswin') ? 'NUL' : '/dev/null'
        end

        # Round the float.
        #
        # @param [Float] float the number
        # @param [Integer] decimals the decimals to round to
        # @return [Float] the rounded float
        #
        def round(float, decimals=4)
          if Float.instance_method(:round).arity == 0 # Ruby 1.8
            factor = 10**decimals
            (float*factor).round / factor.to_f
          else # Ruby 1.9
            float.round(decimals)
          end
        end
      end

    end
  end
end
