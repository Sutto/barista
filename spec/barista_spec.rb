require 'spec_helper'

describe Barista do

  context 'hooks'

  context 'configuration'

  context 'setting app_root' do
    it "defaults to Rails.root" do
      Barista::app_root.should == Rails.root
    end
    it "can be set to another directory" do
      new_path = File.expand_path("../../public/javascripts", __FILE__)
      Barista.configure do |c|
        c.app_root = new_path
      end
      Barista::app_root.to_s.should == new_path
    end
  end

  context 'compiling files'

  context 'compiling all' do
    it "compiles nothing" do
      lambda { Barista::compile_all! false, false }.should_not raise_error
    end
  end

end
