require 'digest/sha2'

module Barista
  class Compiler

    class << self; attr_accessor :bin_path; end
    self.bin_path ||= "coffee"

    def self.available?
      @coffee_available ||= system("which '#{self.bin_path}' >/dev/null 2>&1")
    end

    def self.check_availability!(silence = false)
      available?.tap do |available|
        if Barista.exception_on_error? && !silence
          raise CompilerUnavailableError, "The coffeescript compiler '#{self.bin_path}' could not be found."
        end
      end
    end

    def self.compile(path, options = {})
      new(path, options).to_js
    end

    def initialize(path, options = {})
      @compiled = false
      @options  = {}
      @path     = path
    end

    def compile!
      # Compiler code thanks to bistro_car.
      @compiled_content = invoke_coffee(@path)
      @compiled = true
    end

    def to_js
      compile! unless @compiled
      @compiled_content
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
      result = %x(#{command}).to_s
      if !$?.success?
        if Barista.exception_on_error? && !@options[:silence]
          raise CompilationError, "\"#{command}\" exited with a non-zero status."
        else
          result = nil
        end
      end
      result
    end

    def content_hash
      @content_hash ||= Digest::SHA256.hexdigest(@content)
    end

  end
end
