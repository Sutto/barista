require 'digest/sha2'

module Barista
  class Compiler

    # TODO: Deprecate.
    class << self

      def js_path
        CoffeeScript::Source.path
      end

      def js_path=(value)
        CoffeeScript::Source.path = value
      end
      
      def bin_path
        CoffeeScript::Engines::Node.binary
      end
      
      def bin_path=(path)
        CoffeeScript::Engines::Node.binary = path
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
      
      def setup_default_error_logger!
        Barista.on_compilation_error do |where, message|
          if Barista.verbose?
            Barista.debug "There was an error compiling coffeescript from #{where}:"
            message.each_line { |line| Barista.debug line.rstrip }
          end
        end
      end
      
    end
    
    def initialize(context, options = {})
      @compiled = false
      @options  = {}
      setup_compiler_context context
    end

    def compile!
      location          = @options.fetch(:origin, 'inline')
      @compiled_content = compile(@context, location)
      @compiled_content = preamble(location) + @compiled_content if Barista.add_preamble?
      @compiled         = true
    end

    def to_js
      compile! unless defined?(@compiled) && @compiled
      @compiled_content
    end
    
    def compile(script, where = 'inline')
      Barista.invoke_hook :before_compilation, where
      out = CoffeeScript.compile script, :bare => Barista.bare?
      Barista.invoke_hook :compiled, where
      out
    rescue CoffeeScript::Error => e
      Barista.invoke_hook :compilation_failed, where, e.message
      if Barista.exception_on_error? && !@options[:silence]
        raise CompilationError, "CoffeeScript encountered an error compiling #{where}: #{e.message}"
      end
      compilation_error_for where, e.message
    end

    protected

    def preamble(location)
      "/* DO NOT MODIFY. This file was compiled #{Time.now.httpdate} from\n * #{location.strip}\n */\n\n"
    end
        
    def compilation_error_for(location, message)
      details = "Compilation of '#{location}' failed:\n#{message}"
      Barista.verbose? ?  "alert(#{details.to_json});" : nil
    end
    
    def setup_compiler_context(context)
      if context.respond_to?(:read)
        @context = context.read
        @type    = :string
        default_path = context.respond_to?(:path) ? context.path : 'inline'
        @options[:origin] ||= default_path
      elsif !context.include?("\n") && File.exist?(context)
        @context = File.read(context)
        @type    = :file
        @options[:origin] ||= context
      else
        @context = context.to_s
        @type    = :string
        @options[:origin] ||= 'inline'
      end
    end
    
  end
end
