require "rspec/core/formatters/base_formatter"

module Guard
  class RSpectacle
    class Notifier < RSpec::Core::Formatters::BaseFormatter

      def dump_summary(duration, example_count, failure_count, pending_count)
        ::Guard::Notifier.notify("Test")
      end

    end
  end
end
