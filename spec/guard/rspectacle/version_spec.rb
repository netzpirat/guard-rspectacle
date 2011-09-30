require 'spec_helper'

describe Guard::RSpectacle do
  describe 'VERSION' do
    it 'defines the version' do
      Guard::RSpectacleVersion::VERSION.should match /\d+.\d+.\d+/
    end
  end
end
