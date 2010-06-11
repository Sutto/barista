require 'digest/sha2'

module Barista
  class Compiler
    
    class << self; attr_accessor :bin_path; end
    self.bin_path ||= "coffee"
    
    def self.compile(path)
      new(path).to_js
    end
    
    def initialize(path)
      @compiled = false
      @path     = path
    end
    
    def compile!
      # Compiler code thanks to bistro_car.
      @compiled_content = invoke_coffee(@path)
      @compiled = true
    end
    
    def to_js
      compile! unless @compiled
      @compiled_content.to_s
    end
    
    def self.dirty?(from, to)
      File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
    end
    
    protected
    
    def coffee_options
      ["-p"].tap do |options|
        options << "--no-wrap" if Barista.no_wrap?
      end.join(" ")
    end
    
    def invoke_coffee(path)
      command = "#{self.class.bin_path} #{coffee_options} '#{path}'".squeeze(' ')
      %x(#{command})
    end
    
    def content_hash
      @content_hash ||= Digest::SHA256.hexdigest(@content)
    end
    
  end
end
