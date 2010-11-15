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
    
    def self.compiler=(value)
      name = "Barista::Compilers::#{value.to_s.classify}".constantize
      self.compiler_klass = name
    rescue
      self.compiler_klass = nil
    end
    
    def self.compiler
      compiler_klass.name.underscore.gsub("barista/compilers/", '').to_sym
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

    def self.dirty?(from, to)
      compiler_klass.dirty?(from, to)
    end
  end
end
