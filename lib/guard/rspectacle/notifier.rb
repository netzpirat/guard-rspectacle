require 'rspec/core/formatters/base_formatter'

module Guard
  class RSpectacle

    # Simple RSpec formatter that just stores the last spec run result
    # at class level.
    #
    class Notifier < ::RSpec::Core::Formatters::BaseFormatter

      class << self
        attr_accessor :duration
        attr_accessor :example_count
        attr_accessor :failure_count
        attr_accessor :pending_count
        attr_accessor :failed_specs
        attr_accessor :passed_specs
      end

      def initialize(output)
        super
        @passed_examples = []
      end

      def example_passed(example)
        @passed_examples << example
      end

      def dump_summary(duration, example_count, failure_count, pending_count)
        ::Guard::RSpectacle::Notifier.duration      = duration
        ::Guard::RSpectacle::Notifier.example_count = example_count
        ::Guard::RSpectacle::Notifier.failure_count = failure_count
        ::Guard::RSpectacle::Notifier.pending_count = pending_count
        ::Guard::RSpectacle::Notifier.failed_specs  = @failed_examples.map { |example| example.file_path }.uniq
        ::Guard::RSpectacle::Notifier.passed_specs  = @passed_examples.map { |example| example.file_path }.uniq
      end

    end
  end
end
