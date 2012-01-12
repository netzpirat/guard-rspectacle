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
    runner.stub(:run).and_return [true, []]
    formatter.stub(:notify)
  end

  describe '#initialize' do
    it 'set the last run failed to false' do
      guard.last_run_failed.should be_false
    end

    it 'clears the last failed paths' do
      guard.last_failed_paths.should be_empty
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

      it 'sets a default :all_after_pass option' do
        guard.options[:all_after_pass].should be_true
      end
    end

    context 'with other options than the default ones' do
      let(:guard) { Guard::RSpectacle.new(nil, { :cli            => '--format fuubar',
                                                 :notification   => false,
                                                 :hide_success   => true,
                                                 :all_on_start   => false,
                                                 :keep_failed    => false,
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
      guard.last_run_failed   = true
      guard.last_failed_paths = %w(spec/models/user_spec.rb)
      Dir.stub(:glob).and_return %w(spec/models/user_spec.rb spec/models/role_spec.rb)
      reloader.stub(:reload_file)
    end

    it 'reloads all Ruby files' do
      reloader.should_receive(:reload_file).with('spec/models/user_spec.rb')
      reloader.should_receive(:reload_file).with('spec/models/role_spec.rb')
      guard.reload
    end

    it 'sets last run failed to false' do
      guard.reload
      guard.last_run_failed.should be_false
    end

    it 'sets last failed paths to empty' do
      guard.reload
      guard.last_failed_paths.should be_empty
    end
  end

  describe '.run_all' do
    it 'starts the Runner with the spec dir' do
      runner.should_receive(:run).with(['spec'], defaults).and_return [true, []]
      guard.run_all
    end

    context 'with all specs passing' do
      before do
        guard.last_failed_paths = %w(spec/models/user_spec.rb)
        guard.last_run_failed   = true
        runner.stub(:run).and_return [true, []]
      end

      it 'sets the last run failed to false' do
        guard.run_all
        guard.last_run_failed.should be_false
      end

      it 'clears the list of failed paths' do
        guard.run_all
        guard.last_failed_paths.should be_empty
      end
    end

    context 'with failing specs' do
      before do
        runner.stub(:run).and_return [false, []]
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

      runner.should_receive(:run).with(%w(spec/models/user_spec.rb), defaults).and_return [%w(spec/models/user_spec.rb), true]

      guard.run_on_change(%w(spec/models/user_spec.rb spec/models/role_spec.rb))
    end

    context 'with :keep_failed enabled' do
      let(:guard) { Guard::RSpectacle.new(nil, { :keep_failed => true }) }

      before do
        guard.last_failed_paths = %w(spec/models/role_spec.rb)
      end

      it 'appends the last failed paths to the current run' do
        runner.should_receive(:run).with(%w(spec/models/user_spec.rb spec/models/role_spec.rb), defaults)

        guard.run_on_change(%w(spec/models/user_spec.rb))
      end
    end

    context 'with only success specs' do
      before do
        guard.last_failed_paths = %w(spec/models/user_spec.rb)
        guard.last_run_failed   = true
        runner.stub(:run).and_return [true, []]
      end

      it 'sets the last run failed to false' do
        guard.run_on_change(%w(spec/models/user_spec.rb))
        guard.last_run_failed.should be_false
      end

      it 'removes the passed specs from the list of failed paths' do
        guard.run_on_change(%w(spec/models/user_spec.rb))
        guard.last_failed_paths.should be_empty
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::RSpectacle.new(nil, { :all_after_pass => true }) }

        it 'runs all specs' do
          guard.should_receive(:run_all)
          guard.run_on_change(%w(spec/models/user_spec.rb))
        end
      end

      context 'when :all_after_pass is enabled' do
        let(:guard) { Guard::RSpectacle.new(nil, { :all_after_pass => false }) }

        it 'does not run all specs' do
          guard.should_not_receive(:run_all)
          guard.run_on_change(%w(spec/models/user_spec.rb))
        end
      end
    end

    context 'with failing specs' do
      before do
        guard.last_run_failed = false
        runner.stub(:run).and_return [false, %w(spec/models/user_spec.rb)]
      end

      it 'throws :task_has_failed' do
        expect { guard.run_on_change(%w(spec/models/user_spec.rb)) }.to throw_symbol :task_has_failed
      end

      it 'sets the last run failed to true' do
        expect { guard.run_on_change(%w(spec/models/user_spec.rb)) }.to throw_symbol :task_has_failed
        guard.last_run_failed.should be_true
      end

      it 'appends the failed spec to the list of failed paths' do
        expect { guard.run_on_change(%w(spec/models/user_spec.rb)) }.to throw_symbol :task_has_failed
        guard.last_failed_paths.should =~ %w(spec/models/user_spec.rb)
      end
    end
  end

end
