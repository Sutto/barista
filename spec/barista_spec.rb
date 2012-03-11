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
  
  context 'preamble' do
    before(:each) do
      @assets_path = File.expand_path("../assets", __FILE__)
      @public_path = File.expand_path("../public", __FILE__)
      Barista.configure do |c|
        c.root = @assets_path
        c.output_root = @public_path
      end
      FileUtils.rm_rf @public_path if File.directory?(@public_path)
    end
    it "is written by default" do
      Barista.add_preamble = true
      Barista::compile_all!
      alert_js = IO.read(File.join(@public_path, "alert.js"))
      alert_js.should include "DO NOT MODIFY"
    end
    it "can be disabled" do
      Barista.add_preamble = false
      Barista::compile_all!
      alert_js = IO.read(File.join(@public_path, "alert.js"))
      alert_js.should_not include "DO NOT MODIFY"
    end
  end

  context 'compiling files'

  context 'compiling all' do
    before(:each) do
      @assets_path = File.expand_path("../assets", __FILE__)
      @public_path = File.expand_path("../public", __FILE__)
      Barista.configure do |c|
        c.root = @assets_path
        c.output_root = @public_path
      end
      FileUtils.rm_rf @public_path if File.directory?(@public_path)
    end
    it "compiles nothing" do
      lambda { Barista::compile_all! false, false }.should_not raise_error
    end
    it "produces alert.js" do
      Barista::compile_all!
      File.exist?(File.join(@public_path, "alert.js")).should be_true
    end
    it "logs when verbose is true" do
      log = StringIO.new
      Barista.logger = Logger.new(log)
      Barista.compile_all!
      log.string.should =~ /\[Barista\].+/
    end
    it "does not log when verbose is false" do
      log = StringIO.new
      Barista.logger = Logger.new(log)
      Barista.verbose = false
      Barista.compile_all!
      log.string.should be_empty
    end
  end

end
