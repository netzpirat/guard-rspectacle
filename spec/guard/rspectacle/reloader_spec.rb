# coding: utf-8

require 'spec_helper'

describe Guard::RSpectacle::Reloader do

  let(:reloader) { Guard::RSpectacle::Reloader }
  let(:formatter) { Guard::RSpectacle::Formatter }

  describe '.reload_file' do
    it 'returns false for no Ruby files' do
      reloader.reload_file('fake.txt').should be_false
    end

    it 'returns false when the file does not exist' do
      File.should_receive(:exists?).and_return false
      reloader.reload_file('user.rb').should be_false
    end

    it 'shows a message that the file is reloaded' do
      File.should_receive(:exists?).and_return true
      reloader.stub(:load)
      formatter.should_receive(:info).with('Reload test.rb')
      reloader.reload_file('test.rb')
    end

    it 'loads the file' do
      File.should_receive(:exists?).and_return true
      reloader.should_receive(:load).with('test.rb')
      reloader.reload_file('test.rb')
    end

    context 'when an exception is throw' do
      before do
        File.should_receive(:exists?).and_return true
      end

      it 'shows an error message' do
        reloader.stub(:load).and_raise 'Failure loading file'
        formatter.should_receive(:error).with('Error reloading file test.rb: Failure loading file')
        expect { reloader.reload_file('test.rb') }.to throw_symbol :task_has_failed
      end

      it 'throws :task_has_failed' do
        reloader.stub(:load).and_raise 'Failure loading file'
        expect { reloader.reload_file('test.rb') }.to throw_symbol :task_has_failed
      end
    end
  end

end
