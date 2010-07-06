require 'digest/sha2'

module Barista
  class Compiler

    class << self; attr_accessor :bin_path; end
    self.bin_path ||= "coffee"

    def self.available?
      @coffee_available ||= system("command -v '#{self.bin_path}' >/dev/null 2>&1")
    end

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
      if !$?.success? && Barista.exception_on_error?
        raise Barista::CompilationError
      end
      result
    end

    def content_hash
      @content_hash ||= Digest::SHA256.hexdigest(@content)
    end

  end
end
