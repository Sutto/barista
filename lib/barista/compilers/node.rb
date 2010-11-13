require 'open4'

module Barista
  module Compilers
    class Node < Base
      
      def self.available?
        @node_coffee_available ||= system("test -x '#{Compiler.bin_path}' >/dev/null 2>&1")
      end
      
      protected
      
      def self.legacy_no_wrap?
        @legacy_no_wrap ||= %x('#{Compiler.bin_path}' --help).include?("--no-wrap")
      end
      
      def self.no_wrap_command
        @no_wrap_command ||= (legacy_no_wrap? ? '--no-wrap' : '--bare')
      end
      
      def coffee_options
        ["-p"].tap do |options|
          options << self.class.no_wrap_command if Barista.no_wrap?
        end.join(" ")
      end

      def invoke_coffee(path)
        command = "#{Compiler.bin_path} #{coffee_options} '#{path}'".squeeze(' ')
        Barista.invoke_hook :before_compilation, path

        # jruby cannot use open4 because it uses fork. 
        # This should hopefully work for both jruby and ruby
        popen_class = IO.respond_to?(:popen4) ? IO : Open4

        pid, stdin, stdout, stderr = popen_class.popen4(command)
        stdin.close
        _, status = Process.waitpid2(pid)
        out = stdout.read.strip
        err = stderr.read.strip
        if status.success?
          if err.blank?
            Barista.invoke_hook :compiled, path
          else
            Barista.invoke_hook :compiled_with_warning, path, err
          end
        else
          Barista.invoke_hook :compilation_failed, path, err
          if Barista.exception_on_error? && !@options[:silence]
            raise CompilationError, "\"#{command}\" exited with a non-zero status."
          else
            out = nil
          end
        end
        out
      end
      
    end
  end
end