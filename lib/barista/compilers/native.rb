module Barista
  module Compilers
    class Native < Base
      
      def self.available?
        @native_compiler_available ||= begin
          require 'v8'
          true
        rescue LoadError
          false
        end
      end
      
      def self.coffee_script_source
        File.read(Compiler.js_path)
      end
      
      def self.no_wrap_option
        @no_wrap_option ||= coffee_script_source.include?('noWrap') ? 'noWrap' : 'bare'
      end
      
      def self.coffee_script
        @coffee_script ||= V8::Context.new.tap do |c|
          c.eval(coffee_script_source)
        end["CoffeeScript"]
      end
      
      protected
      
      def coffee_script
        self.class.coffee_script
      end
      
      def invoke_coffee(path)
        script = File.read(path)
        Barista.invoke_hook :before_compilation, path
        out = coffee_script.compile(script, self.class.no_wrap_option => Barista.no_wrap?)
        Barista.invoke_hook :compiled, path
        out
      rescue V8::JSError => e
        Barista.invoke_hook :compilation_failed, path, e.message
        if Barista.exception_on_error? && !@options[:silence]
          raise CompilationError, "CoffeeScript via V8 raised an exception"
        end
        nil
      end
      
    end
  end
end