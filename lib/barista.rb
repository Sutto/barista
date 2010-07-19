require 'active_support'
require 'pathname'

module Barista

  Error                    = Class.new(StandardError)
  CompilationError         = Class.new(Error)
  CompilerUnavailableError = Class.new(Error)

  autoload :Compiler,  'barista/compiler'
  autoload :Filter,    'barista/filter'
  autoload :Framework, 'barista/framework'
  autoload :Hooks,     'barista/hooks'

  class << self

    def hooks
      @hooks ||= Hooks.new
    end
    
    def on_hook(name, *args, &blk)
      hooks.on(name, *args, &blk)
    end
    
    def invoke_hook(name, *args)
      hooks.invoke(name, *args)
    end
    
    def on_compilation_error(&blk)
      on_hook :compilation_failed, &blk
    end
    
    def on_compilation(&blk)
      on_hook :compiled, &blk
    end
    
    def on_compilation_complete(&blk)
      on_hook :all_compiled, &blk
    end

    def on_compilation_with_warning(&blk)
      on_hook :compiled_with_warning, &blk 
    end
    
    def before_compilation(&blk)
      on_hook :before_compilation, &blk
    end

    def configure
      yield self if block_given?
    end

    def exception_on_error?
      @exception_on_error = true if !defined?(@exception_on_error)
      !!@exception_on_error
    end

    def exception_on_error=(value)
      @exception_on_error = value
    end

    def root
      @root ||= Rails.root.join("app", "coffeescripts")
    end

    def root=(value)
      @root = Pathname(value.to_s)
      Framework.default_framework = nil
    end

    def output_root
      @output_root ||= Rails.root.join("public", "javascripts")
    end

    def output_root=(value)
      @output_root = Pathname(value.to_s)
    end

    def compile_file!(file, force = false, silence_error = false)
      # Ensure we have a coffeescript compiler available.
      if !Compiler.check_availability!(silence_error)
        debug "The coffeescript compiler at '#{Compiler.bin_path}' is currently unavailable."
        return ""
      end
      # Expand the path from the framework.
      origin_path, framework = Framework.full_path_for(file)
      return if origin_path.blank?
      destination_path = self.output_path_for(file)
      return unless force || Compiler.dirty?(origin_path, destination_path)
      debug "Compiling #{file} from framework '#{framework.name}'"
      FileUtils.mkdir_p File.dirname(destination_path)
      content = Compiler.compile(origin_path, :silence_error => silence_error)
      # Write the rendered content to file.
      # nil is only when silence_error is true.
      if content.nil?
        debug "An error occured compiling '#{file}' - Leaving file as is."
      else
        File.open(destination_path, "w+") { |f| f.write content }
        content
      end
    rescue SystemCallError
      debug "An unknown error occured attempting to compile '#{file}'"
      ""
    end

    def compile_all!(force = false, silence_error = true)
      debug "Compiling all coffeescripts"
      Framework.exposed_coffeescripts.each do |coffeescript|
        compile_file! coffeescript, force, silence_error
      end
      Barista.invoke_hook :all_compiled
      true
    end

    def change_output_prefix!(framework, prefix = nil)
      framework = framework.is_a?(Barista::Framework) ? framework : Barista::Framework[framework]
      return unless framework
      framework.output_prefix = prefix
    end

    def each_framework(include_default = false)
      Framework.all(include_default).each { |f| yield f if block_given? }
    end

    def output_path_for(file)
      output_root.join(file.to_s.gsub(/^\/+/, '')).to_s.gsub(/\.coffee$/, '.js')
    end

    def debug(message)
      Rails.logger.debug "[Barista] #{message}" if defined?(Rails.logger) && Rails.logger
    end

    # By default, only add it in dev / test
    def add_filter?
      Rails.env.test? || Rails.env.development?
    end

    def no_wrap?
      defined?(@no_wrap) && @no_wrap
    end

    def no_wrap!
      self.no_wrap = true
    end

    def no_wrap=(value)
      @no_wrap = !!value
    end

  end

  if defined?(Rails::Engine)
    class Engine < Rails::Engine

      rake_tasks do
        load File.expand_path('./barista/tasks/barista.rake', File.dirname(__FILE__))
      end

      initializer "barista.wrap_filter" do
        ActionController::Base.before_filter(Barista::Filter) if Barista.add_filter?
      end

    end
  end

end
