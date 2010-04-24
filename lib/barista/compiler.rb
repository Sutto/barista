require 'digest/sha2'

module Barista
  class Compiler
    
    class << self; attr_accessor :bin_path; end
    self.bin_path ||= "coffee"
    
    def self.compile(content)
      new(content).to_js
    end
    
    def initialize(content)
      @compiled = false
      @content  = content
    end
    
    def compile!
      # Compiler code thanks to bistro_car.
      tf = temp_file_for_content
      @compiled_content = invoke_coffee(temp_file_for_content.path)
      @compiled = true
    ensure
      tf.unlink rescue nil
    end
    
    def to_js
      compile! unless @compiled
      @compiled_content.to_s
    end
    
    protected
    
    def coffee_options
      "-p"
    end
    
    def temp_file_for_content
      tf = Tempfile.new("barista-#{content_hash}.coffee")
      tf.write @content
      tf.close
      tf
    end
    
    def invoke_coffee(path)
      command = "#{self.class.bin_path} #{coffee_options} '#{path}'"
      %x(#{command})
    end
    
    def content_hash
      @content_hash ||= Digest::SHA256.hexdigest(@content)
    end
    
  end
end