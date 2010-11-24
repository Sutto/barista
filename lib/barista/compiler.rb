require 'digest/sha2'

module Barista
  class Compiler

    # TODO: Deprecate.
    class << self
      attr_accessor :bin_path, :js_path
      
      def bin_path
        Barista.deprecate! self, :bin_path
        # Do nothing currently.
        nil
      end
      
      def bin_path=(path)
        Barista.deprecate! self, :bin_path=
        # Do nothing currently.
      end
      
      def available?
        CoffeeScript.engine.present? && CoffeeScript.engine.supported?
      end

      def check_availability!(silence = false)
        available = available?        
        if !available && Barista.exception_on_error? && !silence
          raise CompilerUnavailableError, "No method of compiling cofffescript is currently available. Please install therubyracer or node."
        end
        available
      end

      def compile(path, options = {})
        self.new(path, options).to_js
      end
      
      def dirty?(from, to)
        File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
      end
      
    end
    
    def initialize(path, options = {})
      @compiled = false
      @options  = {}
      @path     = path
    end

    def compile!
      @compiled_content = invoke_coffee(@path)
      @compiled_content = preamble + @compiled_content if Barista.add_preamble?
      @compiled         = true
    end

    def to_js
      compile! unless @compiled
      @compiled_content
    end

    protected

    def preamble
      "/* DO NOT MODIFY. This file was compiled from\n * #{@path}\n */\n\n"
    end
    
    def invoke_coffee(path)
      script = File.read(path)
      Barista.invoke_hook :before_compilation, path
      out = CoffeeScript.compile script, :bare => Barista.bare?
      Barista.invoke_hook :compiled, path
      out
    rescue CoffeeScript::Error => e
      Barista.invoke_hook :compilation_failed, path, e.message
      if Barista.exception_on_error? && !@options[:silence]
        raise CompilationError, "CoffeeScript encountered an error: #{e.message}"
      end
      nil
    end
    
  end
end
