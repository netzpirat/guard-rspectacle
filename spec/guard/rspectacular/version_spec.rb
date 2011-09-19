require 'spec_helper'

describe Guard::RSpectacularVersion do
  describe 'VERSION' do
    it 'defines the version' do
      Guard::RSpectacularVersion::VERSION.should match /\d+.\d+.\d+/
    end
  end
end
