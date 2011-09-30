require 'spec_helper'

describe Guard::RSpecRails do

  let(:guard) { Guard::RSpecRails.new }

  let(:runner) { Guard::RSpecRails::Runner }
  let(:inspector) { Guard::RSpecRails::Inspector }
  let(:formatter) { Guard::RSpecRails::Formatter }

  let(:defaults) { Guard::RSpecRails::DEFAULT_OPTIONS }

  describe '.start' do
  end

  describe '.reload' do
  end

  describe '.run_all' do
  end

  describe '.run_on_change' do
  end

end
