# coding: utf-8

require 'spec_helper'

describe Guard::RSpectacle::Humanity do

  describe '.success' do
    it 'returns a success message' do
      described_class.success.should be_a String
    end

    it 'returns a random message' do
      (1..10).map{ described_class.success }.uniq.size.should > 1
    end
  end

  describe '.failure' do
    it 'returns a failure message' do
      described_class.success.should be_a String
    end

    it 'returns a random message' do
      (1..10).map{ described_class.failure }.uniq.size.should > 1
    end
  end

end
