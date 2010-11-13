require 'digest/sha2'

module Barista
  class Compiler

    class << self
      attr_accessor :bin_path, :js_path
    end
    self.bin_path ||= "coffee"
    self.js_path  ||= File.expand_path('../coffee-script/coffee-script-0.9.4.js', File.dirname(__FILE__))

    def self.compilers
      [Compilers::Native, Compilers::Node]
    end
    
    def self.compiler_klass
      @compiler_klass ||= compilers.detect(&:available?)
    end
    
    def self.compiler_klass=(value)
      @compiler_klass = value.present? ? value : nil
    end

    def self.available?
      compiler_klass.present?
    end

    def self.check_availability!(silence = false)
      available?.tap do |available|
        if !available && Barista.exception_on_error? && !silence
          raise CompilerUnavailableError, "A coffee script compiler is currently unavailable. Please install therubyracer or coffee-script via node"
        end
      end
    end

    def self.compile(path, options = {})
      compiler_klass.new(path, options).to_js
    end
  end
end
