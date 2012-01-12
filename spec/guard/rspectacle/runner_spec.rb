# coding: utf-8

require 'spec_helper'

describe Guard::RSpectacle::Runner do

  let(:runner) { Guard::RSpectacle::Runner }

  before do
    ::RSpec::Core::Runner.stub(:run)
  end

  describe '#run' do
    it 'merges the files and the cli options' do
      ::RSpec::Core::Runner.should_receive(:run).with(%w(a_spec.rb b_spec.rb --format Fuubar --backtrace --tag @focus), kind_of(IO), kind_of(IO))
      runner.run(%w(a_spec.rb b_spec.rb), '--format Fuubar --backtrace --tag @focus')
    end

    it 'returns true when specs have passed' do
      ::RSpec::Core::Runner.should_receive(:run).and_return 0
      runner.run(%w(a_spec.rb b_spec.rb), '').should be_true
    end

    it 'returns false when specs have failed' do
      ::RSpec::Core::Runner.should_receive(:run).and_return -1
      runner.run(%w(a_spec.rb b_spec.rb), '').should be_false
    end
  end

end
