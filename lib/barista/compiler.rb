require 'digest/sha2'

module Barista
  class Compiler

    UNAVAILABLE_MESSAGE = "No method of compiling coffee-script is currently available. Please see the ExecJS page (https://github.com/sstephenson/execjs) for details on how to set one up."

    # TODO: Deprecate.
    class << self

      def js_path
        CoffeeScript::Source.path
      end

      def js_path=(value)
        CoffeeScript::Source.path = value
      end

      def bin_path
        execjs_runtime_call :binary
      end

      def bin_path=(path)
        execjs_runtime_call :binary=, path
      end

      def execjs_runtime_call(method, *args)
        runtime = ExecJS.runtime
        if runtime.respond_to?(method, true)
          runtime.send method, *args
        else
          nil
        end
      end

      def available?
        ExecJS.runtime and ExecJS.runtime.available?
      end

      def check_availability!(silence = false)
        available = available?
        if !available && Barista.exception_on_error? && !silence
          raise CompilerUnavailableError, UNAVAILABLE_MESSAGE
        end
        available
      end

      def compile(content, options = {})
        self.new(content, options).to_js
      end

      def autocompile_file(file, force = false, silence_error = false)
        # Expand the path from the framework.
        origin_path, framework = Framework.full_path_for(file)
        return if origin_path.nil?
        destination_path = framework.output_path_for(file)

        # read file directly if auto_compile is disabled
        if !Barista.auto_compile?
          if File.exist?(destination_path)
            return File.read(destination_path)
          else
            return nil
          end
        end

        return File.read(destination_path) unless dirty?(origin_path, destination_path) || force
        # Ensure we have a coffeescript compiler available.
        if !check_availability!(silence_error)
          Barista.debug UNAVAILABLE_MESSAGE
          return nil
        end
        Barista.debug "Compiling #{file} from framework '#{framework.name}'"
        compiler = new(origin_path, :silence_error => silence_error, :output_path => destination_path)
        content = compiler.to_js
        compiler.save
        content
      end

      def compile_as(file, type)
        origin_path, framework = Framework.full_path_for(file)
        return if origin_path.nil?
        if type == :coffeescript
          return File.read(origin_path), File.mtime(origin_path)
        else
          return autocompile_file(file), Time.now
        end
      end

      def dirty?(from, to)
        File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
      end

      def setup_default_error_logger
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
      @options  = options
      setup_compiler_context context
    end

    def compile!
      location          = @options.fetch(:origin, 'inline')
      @compiled_content = compile(@context, location)
      @compiled_content = preamble(location) + @compiled_content if location != 'inline' && Barista.add_preamble?
      @compiled         = true
    end
    
    def to_js
      compile! unless defined?(@compiled) && @compiled
      @compiled_content
    end

    def copyable?(location)
      location != 'inline' && File.extname(location) == '.js'
    end

    def compile(script, where = 'inline')
      if copyable?(where)
        out = script
      else
        Barista.invoke_hook :before_compilation, where
        out = CoffeeScript.compile script, :bare => Barista.bare?
        Barista.invoke_hook :compiled, where
      end
      out
    rescue ExecJS::Error => e
      Barista.invoke_hook :compilation_failed, where, e.message
      if Barista.exception_on_error? && !@options[:silence]
        if e.is_a?(ExecJS::ProgramError)
          where_within_app = where.sub(/#{Regexp.escape(Barista.app_root.to_s)}\/?/, '')
          raise CompilationError, "Error: In #{where_within_app}, #{e.message}"
        else
          raise CompilationError, "CoffeeScript encountered an error compiling #{where}: #{e.message}"
        end
      end
      compilation_error_for where, e.message
    end

    def save(path = @options[:output_path])
      return false unless path.is_a?(String) && !to_js.nil?
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, "w+") { |f| f.write @compiled_content }
      true
    rescue Errno::EACCES
      false
    end

    protected

    def preamble(location)
      inner_message = copyable?(location) ? "copied" : "compiled"
      if Barista.preamble
        Barista.preamble.call(location)
      else
        "/* DO NOT MODIFY. This file was #{inner_message} #{Time.now.httpdate} from\n * #{location.strip}\n */\n\n"
      end
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
