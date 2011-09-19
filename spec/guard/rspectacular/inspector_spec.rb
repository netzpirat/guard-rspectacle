require 'spec_helper'

describe Guard::RSpectacular::Inspector do
  before do
    Dir.stub(:glob).and_return ['spec/models/model_spec.rb', 'spec/constrollers/test_controller_spec.rb']
  end

  subject { Guard::RSpectacular::Inspector }

  describe 'clean' do
    it 'allows the RSpec spec dir' do
      subject.clean(['spec', 'spec/models/model_spec.rb']).should == ['spec']
    end

    it 'removes duplicate files' do
      subject.clean(['spec/models/model_spec.rb', 'spec/models/model_spec.rb']).should == ['spec/models/model_spec.rb']
    end

    it 'remove nil files' do
      subject.clean(['spec/models/model_spec.rb', nil]).should == ['spec/models/model_spec.rb']
    end

    it 'removes files that are no rspec specs' do
      subject.clean(['spec/models/model_spec.rb',
                     'app/models/model.rb',
                     'b.txt']).should == ['spec/models/model_spec.rb']
    end

  end
end
