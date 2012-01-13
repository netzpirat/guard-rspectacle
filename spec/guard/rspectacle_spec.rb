require 'spec_helper'

describe Guard::RSpectacle do

  let(:guard) { Guard::RSpectacle.new }

  let(:runner) { Guard::RSpectacle::Runner }
  let(:inspector) { Guard::RSpectacle::Inspector }
  let(:formatter) { Guard::RSpectacle::Formatter }
  let(:reloader) { Guard::RSpectacle::Reloader }

  let(:defaults) { Guard::RSpectacle::DEFAULT_OPTIONS }

  before do
    inspector.stub(:clean).and_return { |specs| specs }
    runner.stub(:run).and_return [true, [], [], []]
    formatter.stub(:notify)
  end

  describe '#initialize' do
    it 'set the last run passed to true' do
      guard.last_run_passed.should be_true
    end

    it 'clears the last failed paths' do
      guard.rerun_examples.should be_empty
    end

    context 'when no options are provided' do
      it 'sets a default :cli option' do
        guard.options[:cli].should eql ''
      end

      it 'sets a default :notification option' do
        guard.options[:notification].should be_true
      end

      it 'sets a default :hide_on_success option' do
        guard.options[:hide_on_success].should be_false
      end

      it 'sets a default :all_on_start option' do
        guard.options[:all_on_start].should be_true
      end

      it 'sets a default :keep_failed option' do
        guard.options[:keep_failed].should be_true
      end

      it 'sets a default :keep_failed option' do
        guard.options[:keep_failed].should be_true
      end

      it 'sets a default :keep_pending option' do
        guard.options[:keep_pending].should be_true
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::RSpectacle.new(nil, { :cli            => '--format fuubar',
                                                 :notification   => false,
                                                 :hide_success   => true,
                                                 :all_on_start   => false,
                                                 :keep_failed    => false,
                                                 :keep_pending   => false,
                                                 :all_after_pass => false }) }

      it 'sets the :cli option' do
        guard.options[:cli].should eql '--format fuubar'
      end

      it 'sets the :notification option' do
        guard.options[:notification].should be_false
      end

      it 'sets the :hide_success option' do
        guard.options[:hide_success].should be_true
      end

      it 'sets the :all_on_start option' do
        guard.options[:all_on_start].should be_false
      end

      it 'sets the :keep_failed option' do
        guard.options[:keep_failed].should be_false
      end

      it 'sets the :keep_pending option' do
        guard.options[:keep_pending].should be_false
      end

      it 'sets the :all_after_pass option' do
        guard.options[:all_after_pass].should be_false
      end
    end
  end

  describe '.start' do
    before do
      guard.stub(:run_all)
    end

    context 'without a Rails environment' do
      before do
        ENV['RAILS_ENV'] = nil
      end

      it 'sets the Rails environment to test' do
        guard.start
        ENV['RAILS_ENV'].should eql 'test'
      end

      it 'shows the current environment' do
        formatter.should_receive(:info).with('RSpectacle is ready in test environment.')
        guard.start
      end
    end

    context 'with a Rails environment' do
      it 'keeps the Rails environment' do
        ENV['RAILS_ENV'] = 'cucumber'
        guard.start
        ENV['RAILS_ENV'].should eql 'cucumber'
      end

      it 'shows the current environment' do
        formatter.should_receive(:info).with('RSpectacle is ready in cucumber environment.')
        guard.start
      end
    end

    context 'with :all_on_start set to true' do
      let(:guard) { Guard::RSpectacle.new(nil, { :all_on_start => true }) }

      it 'triggers .run_all' do
        guard.should_receive(:run_all).and_return true
        guard.start
      end
    end

    context 'with :all_on_start set to false' do
      let(:guard) { Guard::RSpectacle.new(nil, { :all_on_start => false }) }

      it 'does not trigger .run_all' do
        guard.should_not_receive(:run_all)
        guard.start
      end
    end
  end

  describe '.reload' do
    before do
      guard.last_run_passed = true
      guard.rerun_examples  = %w(spec/models/user_spec.rb)
      Dir.stub(:glob).and_return %w(spec/models/user_spec.rb spec/models/role_spec.rb)
      reloader.stub(:reload_file)
    end

    it 'reloads all Ruby files' do
      reloader.should_receive(:reload_file).with('spec/models/user_spec.rb')
      reloader.should_receive(:reload_file).with('spec/models/role_spec.rb')
      guard.reload
    end

    it 'sets last run passed to true' do
      guard.reload
      guard.last_run_passed.should be_true
    end

    it 'sets last failed paths to empty' do
      guard.reload
      guard.rerun_examples.should be_empty
    end
  end

  describe '.run_all' do
    it 'starts the Runner with the spec dir' do
      runner.should_receive(:run).with(['spec'], defaults.merge({ :message => 'Run all specs'})).and_return [true, [], [], []]
      guard.run_all
    end

    context 'when keeping the pending examples' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_pending => true }) }

      it 'adds the failed and the pending examples to the examples to be rerun' do
        runner.stub(:run).and_return [true, %w(spec/models/role_spec.rb), [], %w(spec/models/user_spec.rb)]
        guard.run_all
        guard.rerun_examples.should =~ %w(spec/models/role_spec.rb spec/models/user_spec.rb)
      end
    end

    context 'without keeping the pending examples' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_pending => false }) }

      it 'adds the only the failed examples to the examples to be rerun' do
        runner.stub(:run).and_return [true, %w(spec/models/role_spec.rb), %w(spec/models/user_spec.rb), []]
        guard.run_all
        guard.rerun_examples.should =~ %w(spec/models/role_spec.rb)
      end
    end

    context 'when passing passing the run' do
      before do
        guard.last_run_passed = false
        runner.stub(:run).and_return [true, [], [], []]
      end

      it 'sets the last run passed to true' do
        guard.run_all
        guard.last_run_passed.should be_true
      end
    end

    context 'when not passing the run' do
      before do
        guard.last_run_passed = true
        runner.stub(:run).and_return [false, %w(spec/models/role_spec.rb), [], []]
      end

      it 'sets the last run passed to false' do
        catch(:task_has_failed) { guard.run_all }
        guard.last_run_passed.should be_false
      end

      it 'throws :task_has_failed' do
        expect { guard.run_all }.to throw_symbol :task_has_failed
      end
    end
  end

  describe '.run_on_change' do
    it 'passes the paths to the Inspector for cleanup' do
      inspector.should_receive(:clean).with(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
      guard.run_on_change(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
    end

    it 'returns false when no valid paths are passed' do
      inspector.should_receive(:clean).and_return []
      guard.run_on_change(%w(spec/models/role_spec.rb)).should be_false
    end

    it 'reloads changed non-spec files' do
      inspector.should_receive(:clean).and_return %w(spec/models/user_spec.rb)
      reloader.should_receive(:reload_file).with('app/models/user.rb')
      guard.run_on_change(%w(spec/models/user_spec.rb app/models/user.rb))
    end

    it 'starts the Runner with the cleaned files' do
      inspector.should_receive(:clean).with(%w(spec/models/user_spec.rb spec/models/role_spec.rb)).and_return %w(spec/models/user_spec.rb)
      runner.should_receive(:run).with(%w(spec/models/user_spec.rb), defaults).and_return [true, %w(spec/models/user_spec.rb), [], []]
      guard.run_on_change(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
    end

    context 'with :keep_failed enabled' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_failed => true }) }

      before do
        guard.rerun_examples = %w(spec/models/role_spec.rb)
      end

      it 'appends the last failed paths to the current run' do
        runner.should_receive(:run).with(%w(spec/models/user_spec.rb spec/models/role_spec.rb), defaults)
        guard.run_on_change(%w(spec/models/user_spec.rb))
      end
    end

    context 'when keeping the pending examples' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_pending => true }) }

      before do
        guard.rerun_examples = %w(spec/models/permission_spec.rb)
      end

      it 'adds the failed and the pending examples to the examples to be rerun' do
        runner.stub(:run).and_return [true, %w(spec/models/role_spec.rb), [], %w(spec/models/user_spec.rb)]
        guard.run_on_change(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
        guard.rerun_examples.should =~ %w(spec/models/permission_spec.rb spec/models/role_spec.rb spec/models/user_spec.rb)
      end
    end

    context 'without keeping the pending examples' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_pending => false }) }

      before do
        guard.rerun_examples = %w(spec/models/permission_spec.rb)
      end

      it 'adds the only the failed examples to the examples to be rerun' do
        runner.stub(:run).and_return [true, %w(spec/models/role_spec.rb), %w(spec/models/user_spec.rb), []]
        guard.run_on_change(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
        guard.rerun_examples.should =~ %w(spec/models/permission_spec.rb spec/models/role_spec.rb)
      end
    end

    context 'when passing passing the run' do
      before do
        guard.stub(:run_all)
        guard.last_run_passed = false
        guard.rerun_examples = %w(spec/models/permission_spec.rb spec/models/role_spec.rb)
        runner.stub(:run).and_return [true, [], %w(spec/models/permission_spec.rb), []]
      end

      it 'sets the last run passed to true' do
        guard.run_on_change(%w(spec/models/permission_spec.rb ))
        guard.last_run_passed.should be_true
      end

      it 'removes the passed examples from the rerun examples' do
        guard.run_on_change(%w(spec/models/permission_spec.rb))
        guard.rerun_examples.should =~ %w(spec/models/role_spec.rb)
      end

      context 'given the :all_after_pass option' do
        let(:guard) { Guard::RSpectacle.new(nil, { :all_after_pass => true }) }

        before do
          guard.last_run_passed = false
          guard.rerun_examples = %w(spec/models/permission_spec.rb)
        end

        it 'runs all specs' do
          runner.stub(:run).and_return [true, [], %w(spec/models/permission_spec.rb), []]
          guard.should_receive(:run_all)
          guard.run_on_change(%w(spec/models/permission_spec.rb))
        end
      end
    end

    context 'when not passing the run' do
      before do
        guard.last_run_passed = true
        runner.stub(:run).and_return [false, %w(spec/models/role_spec.rb), [], []]
      end

      it 'sets the last run passed to false' do
        catch(:task_has_failed) { guard.run_on_change(%w(spec/models/role_spec.rb)) }
        guard.last_run_passed.should be_false
      end

      it 'throws :task_has_failed' do
        expect { guard.run_on_change(%w(spec/models/role_spec.rb)) }.to throw_symbol :task_has_failed
      end
    end

  end

end
