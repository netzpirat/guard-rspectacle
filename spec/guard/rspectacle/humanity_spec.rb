require 'spec_helper'

describe Guard::RSpectacle::Humanity do

  its(:success) { should be_a String }
  its(:failure) { should be_a String }

  its(:success) { should_not be_empty }
  its(:failure) { should_not be_empty }

  describe "#success" do
    it "should be random" do
      (1..10).map{ subject.success }.uniq.size.should > 1
    end
  end

  describe "#failure" do
    it "should be random" do
      (1..10).map{ subject.failure }.uniq.size.should > 1
    end
  end
end
