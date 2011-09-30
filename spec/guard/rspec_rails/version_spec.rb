require 'spec_helper'

describe Guard::RSpecRails do
  describe 'VERSION' do
    it 'defines the version' do
      Guard::RSpecRailsVersion::VERSION.should match /\d+.\d+.\d+/
    end
  end
end
