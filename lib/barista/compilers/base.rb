module Barista
  module Compilers
    class Base
      
      def self.available?
        false
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

      def self.dirty?(from, to)
        File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
      end

      protected

      def preamble
        "/* DO NOT MODIFY. This file was compiled from\n *   #{@path}\n */\n\n"
      end
      
      
    end
  end
end