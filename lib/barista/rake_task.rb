require 'barista' unless defined?(Barista)
require 'rake'
require 'rake/tasklib'

module Barista
  class RakeTask < ::Rake::TaskLib

    attr_writer :namespace, :task_name
    attr_writer :environment, :input_directory, :output_directory, :rails

    def initialize
      yield self if block_given?
      @namespace ||= :barista
      @task_name ||= :brew
      @task_name = @task_name.to_sym
      @rails     = defined?(Rails) if @rails.nil?

      task_declaration = (@rails ? {@task_name => :environment} : @task_name)

      namespace @namespace do
        desc "Compiles all CoffeeScript sources to JavaScript"
        task task_declaration do
          setup_barista
          check_availability
          puts "Compiling all CoffeeScripts to their JavaScript equivalent."
          Barista.compile_all! true, false
        end
      end
    end

    # Proxy methods for rake tasks

    def respond_to?(method, include_private = false)
      super || Barista.respond_to?(method, include_private)
    end

    def method_missing(method, *args, &blk)
      if Barista.respond_to?(method)
        Barista.send method, *args, &blk
      else
        super
      end
    end

    private

    def setup_barista
      Barista.env = @environment if @environment
      if @input_directory
        Barista.root = File.expand_path(@input_directory, Dir.pwd)
      end
      if @output_directory
        Barista.output_root = File.expand_path(@output_directory, Dir.pwd)
      end
    end

    def check_availability
      unless Barista::Compiler.available?
        warn Barista::Compiler::UNAVAILABLE_MESSAGE
        exit 1
      end
    end

  end
end