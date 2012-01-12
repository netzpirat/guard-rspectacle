# coding: utf-8

require 'spec_helper'

describe Guard::RSpectacle::Runner do

  let(:runner) { Guard::RSpectacle::Runner }
  let(:formatter) { Guard::RSpectacle::Formatter }
  let(:defaults) { Guard::RSpectacle::DEFAULT_OPTIONS }

  before do
    ::RSpec::Core::Runner.stub(:run)
    ::Guard::RSpectacle::Formatter.stub(:notify)
  end

  describe '#run' do
    it 'merges the files and the cli options' do
      ::RSpec::Core::Runner.should_receive(:run).with(%w(a_spec.rb b_spec.rb --format Fuubar --backtrace --tag @focus), kind_of(IO), kind_of(IO))
      runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :cli => '--format Fuubar --backtrace --tag @focus' }))
    end

    context 'given all specs have passed' do
      it 'returns true as passed status' do
        ::RSpec::Core::Runner.should_receive(:run).and_return 0
        runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :cli => '' })).should =~ [true, []]
      end

      context 'with notifications enabled' do
        context 'with hide success disabled' do
          it 'shows the success message' do
            ::RSpec::Core::Runner.stub(:run).and_return 0
            formatter.should_receive(:notify).with(kind_of(String), { :image => :success })
            runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :notification => true, :hide_success => false }))
          end
        end

        context 'with hide success enabled' do
          it 'does not show the success message' do
            ::RSpec::Core::Runner.stub(:run).and_return 0
            formatter.should_not_receive(:notify).with(kind_of(String), { :image => :success })
            runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :notification => true, :hide_success => true }))
          end
        end
      end

      context 'with notifications disabled' do
        it 'does not show the success message' do
          ::RSpec::Core::Runner.stub(:run).and_return 0
          formatter.should_not_receive(:notify).with(kind_of(String), { :image => :success })
          runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :notification => false }))
        end
      end
    end

    context 'given some specs have failed' do
      it 'returns false as passed status' do
        ::RSpec::Core::Runner.should_receive(:run).and_return -1
        runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :cli => '' })).should =~ [false, []]
      end

      context 'with notifications enabled' do
        it 'shows the failed message' do
          ::RSpec::Core::Runner.stub(:run).and_return -1
          formatter.should_receive(:notify).with(kind_of(String), { :image => :failed })
          runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :notification => true }))
        end
      end

      context 'with notifications disabled' do
        it 'does not show the failed message' do
          ::RSpec::Core::Runner.stub(:run).and_return -1
          formatter.should_not_receive(:notify).with(kind_of(String), { :image => :failed })
          runner.run(%w(a_spec.rb b_spec.rb), defaults.merge({ :notification => false }))
        end
      end
    end
  end

end
