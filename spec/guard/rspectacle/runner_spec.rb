# coding: utf-8

require 'spec_helper'

describe Guard::RSpectacle::Runner do

  let(:runner) { Guard::RSpectacle::Runner }
  let(:formatter) { Guard::RSpectacle::Formatter }

  let(:defaults) { Guard::RSpectacle::DEFAULT_OPTIONS }
  let(:options) { Guard::RSpectacle::Runner.send(:rspectacular_options) }

  before do
    ::RSpec::Core::Runner.stub(:run)
    ::Guard::RSpectacle::Formatter.stub(:notify)
  end

  describe '#run' do
    it 'merges the files and the cli options' do
      ::RSpec::Core::Runner.should_receive(:run).with(%w(--format Fuubar --backtrace --tag @focus) + options + %w(a_spec.rb b_spec.rb), kind_of(IO), kind_of(IO))
      runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :cli => '--format Fuubar --backtrace --tag @focus' }))
    end

    it 'removes the --drb option' do
      ::RSpec::Core::Runner.should_receive(:run).with(%w(--format Fuubar --backtrace --tag @focus) + options + %w(a_spec.rb b_spec.rb), kind_of(IO), kind_of(IO))
      runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :cli => '--drb --format Fuubar --backtrace --tag @focus' }))
    end

    context 'without a message option' do
      it 'shows an info message with all the examples to run' do
        ::Guard::UI.should_receive(:info).with('Run specs a_spec.rb b_spec.rb', { :reset=>true })
        runner.run(%w(a_spec.rb b_spec.rb), defaults)
      end
    end

    context 'with a message option' do
      it 'shows the given message' do
        ::Guard::UI.should_receive(:info).with('Running all specs', { :reset=>true })
        runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :message => 'Running all specs' }))
      end
    end

    context 'given the spec run is successful' do
      before do
        ::RSpec::Core::Runner.stub(:run).and_return 0
        ::Guard::RSpectacle::Humanity.stub(:success).and_return('Well done, mate!')
        ::Guard::RSpectacle::Notifier.failed_examples  = []
        ::Guard::RSpectacle::Notifier.passed_examples  = %w(app/model/user_spec.rb app/model/role_spec.rb app/model/permission_spec.rb)
        ::Guard::RSpectacle::Notifier.pending_examples = []
        ::Guard::RSpectacle::Notifier.duration         = 5.1234567
        ::Guard::RSpectacle::Notifier.example_count    = 3
        ::Guard::RSpectacle::Notifier.failure_count    = 0
        ::Guard::RSpectacle::Notifier.pending_count    = 0
      end

      it 'returns the rspec success status' do
        runner.run(%w(app/model/user_spec.rb), defaults).should =~ [
            true,
            [],
            %w(app/model/user_spec.rb app/model/role_spec.rb app/model/permission_spec.rb),
            []
        ]
      end

      context 'with notifications enabled' do
        it 'shows a successful spec notification' do
          formatter.should_receive(:notify).with("Well done, mate! 3 examples, 0 failures\nin 5.1235 seconds", {
              :title    => 'RSpec results',
              :image    => :success,
              :priority => 2 })
          runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb app/model/permission_spec.rb),
                     defaults.merge({ :notification => true, :hide_success => false }))
        end

        context 'with hide on success enabled' do
          it 'does not show a successful spec notification' do
            formatter.should_not_receive(:notify).with("Well done, mate! 3 examples, 0 failures\nin 5.1235 seconds", {
                :title    => 'RSpec results',
                :image    => :success,
                :priority => 2 })
            runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb app/model/permission_spec.rb),
                       defaults.merge({ :notification => true, :hide_success => true }))
          end
        end
      end

      context 'with notifications disabled' do
        it 'does not show a successful spec notification' do
          formatter.should_not_receive(:notify).with("Well done, mate! 3 examples, 0 failures\nin 5.1235 seconds", {
              :title    => 'RSpec results',
              :image    => :success,
              :priority => 2 })
          runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb app/model/permission_spec.rb),
                     defaults.merge({ :notification => false, :hide_success => false }))
        end
      end
    end

    context 'given the spec run has pending examples' do
      before do
        ::RSpec::Core::Runner.stub(:run).and_return 0
        ::Guard::RSpectacle::Humanity.stub(:pending).and_return('Final spurt!')
        ::Guard::RSpectacle::Notifier.failed_examples  = []
        ::Guard::RSpectacle::Notifier.passed_examples  = %w(app/model/user_spec.rb)
        ::Guard::RSpectacle::Notifier.pending_examples = %w(app/model/role_spec.rb)
        ::Guard::RSpectacle::Notifier.duration         = 6.9876543
        ::Guard::RSpectacle::Notifier.example_count    = 2
        ::Guard::RSpectacle::Notifier.failure_count    = 0
        ::Guard::RSpectacle::Notifier.pending_count    = 1
      end

      it 'returns the rspec success status' do
        runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb), defaults).should =~ [
            true,
            [],
            %w(app/model/user_spec.rb),
            %w(app/model/role_spec.rb)
        ]
      end

      context 'with notifications enabled' do
        it 'shows a successful spec notification' do
          formatter.should_receive(:notify).with("Final spurt! 2 examples, 0 failures (1 pending)\nin 6.9877 seconds", {
              :title    => 'RSpec results',
              :image    => :pending,
              :priority => -1 })
          runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb),
                     defaults.merge({ :notification => true, :hide_success => false }))
        end
      end

      context 'with notifications disabled' do
        it 'does not show a successful spec notification' do
          formatter.should_not_receive(:notify).with("Final spurt! 2 examples, 0 failures (1 pending)\nin 6.9877 seconds", {
              :title    => 'RSpec results',
              :image    => :pending,
              :priority => -1 })
          runner.run(%w(app/model/user_spec.rb app/model/role_spec.rb),
                     defaults.merge({ :notification => false, :hide_success => false }))
        end
      end
    end

    context 'given the spec run has failures' do
      before do
        ::RSpec::Core::Runner.stub(:run).and_return -1
        ::Guard::RSpectacle::Humanity.stub(:failure).and_return('Failing, not there yet...')
        ::Guard::RSpectacle::Notifier.failed_examples  = %w(app/model/user_spec.rb)
        ::Guard::RSpectacle::Notifier.passed_examples  = []
        ::Guard::RSpectacle::Notifier.pending_examples = []
        ::Guard::RSpectacle::Notifier.duration         = 12.1934523
        ::Guard::RSpectacle::Notifier.example_count    = 1
        ::Guard::RSpectacle::Notifier.failure_count    = 1
        ::Guard::RSpectacle::Notifier.pending_count    = 0
      end

      it 'returns the rspec success status' do
        runner.run(%w(app/model/user_spec.rb), defaults).should =~ [
            false,
            %w(app/model/user_spec.rb),
            [],
            []
        ]
      end

      context 'with notifications enabled' do
        it 'shows a successful spec notification' do
          formatter.should_receive(:notify).with("Failing, not there yet... 1 example, 1 failure\nin 12.1935 seconds", {
              :title    => 'RSpec results',
              :image    => :failed,
              :priority => -2 })
          runner.run(%w(app/model/user_spec.rb), defaults.merge({ :notification => true, :hide_success => false }))
        end
      end

      context 'with notifications disabled' do
        it 'does not show a successful spec notification' do
          formatter.should_not_receive(:notify).with("Failing, not there yet... 1 example, 1 failure\nin 12.1935 seconds", {
              :title    => 'RSpec results',
              :image    => :failed,
              :priority => -2 })
          runner.run(%w(app/model/user_spec.rb), defaults.merge({ :notification => false, :hide_success => false }))
        end
      end
    end

  end

end
