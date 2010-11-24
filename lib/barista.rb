require 'active_support'
require 'pathname'

require 'coffee_script'

module Barista

  Error                    = Class.new(StandardError)
  CompilationError         = Class.new(Error)
  CompilerUnavailableError = Class.new(Error)

  autoload :Compiler,  'barista/compiler'
  autoload :Filter,    'barista/filter'
  autoload :Framework, 'barista/framework'
  autoload :Hooks,     'barista/hooks'
  autoload :Server,    'barista/server'

  autoload :Extensions, 'barista/extensions'

  class << self
    include Extensions

    # Hook methods
    #
    # Hooks are a generic way to define blocks that are executed at run time.
    # For a full list of hooks, see the readme.

    def hooks
      @hooks ||= Hooks.new
    end
    
    def on_hook(name, *args, &blk)
      hooks.on(name, *args, &blk)
    end
    
    def invoke_hook(name, *args)
      hooks.invoke(name, *args)
    end
    
    has_hook_method :on_compilation_error        => :compilation_failed,
                    :on_compilation              => :compiled,
                    :on_compilation_complete     => :all_compiled,
                    :on_compilation_with_warning => :compiled_with_warning,
                    :before_full_compilation     => :before_full_compilation,
                    :before_compilation          => :before_compilation


    # Configuration - Tweak how you use Barista.
    
    def configure
      yield self if block_given?
    end
    
    def env
      @env ||= default_for_env
    end

    def env=(value)
      @env = value.to_s.strip
      @env = nil if @env == ''
    end
    
    def logger
      @logger ||= default_for_logger
    end

    def logger=(value)
      @logger = value
    end

    def app_root
      @app_root ||= default_for_app_root
    end

    def app_root=(value)
      @app_root = value.nil? ? nil : Pathname(value.to_s)
    end

    def root
      @root ||= app_root.join("app", "coffeescripts")
    end

    def root=(value)
      @root = value.nil? ? nil : Pathname(value.to_s)
      Framework.default_framework = nil
    end

    def output_root
      @output_root ||= app_root.join("public", "javascripts")
    end

    def output_root=(value)
      @output_root = value.nil? ? nil : Pathname(value.to_s)
    end

    has_boolean_options :verbose, :bare, :add_filter, :add_preamble, :exception_on_error

    def no_wrap?
      deprecate! self, :no_wrap?, 'Please use bare? instead.'
      bare?
    end

    def no_wrap!
      deprecate! self, :no_wrap!, 'Please use bare! instead.'
      bare!
    end

    def no_wrap=(value)
      deprecate! self, :no_wrap=, 'Please use bare= instead.'
      self.bare = value
    end

    delegate :bin_path, :bin_path=, :js_path, :js_path=, :to => Compiler

    [:compiler, :compiler=, :compiler_klass, :compiler_klass=].each do |m|
      define_method(m) do
        deprecate! self, m
        nil
      end
    end

    # Default configuration options

    def default_for_env
      return Rails.env.to_s if defined?(Rails.env)
      ENV['RAILS_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def default_for_app_root
      if defined?(Rails.root)
        Rails.root
      else
        Pathname(Dir.pwd)
      end
    end

    def default_for_logger
      if defined?(Rails.logger)
        Rails.logger
      else
        require 'logger'
        Logger.new(STDOUT)
      end
    end

    def default_for_verbose
      %w(test development).include? Barista.env
    end

    def default_for_add_filter
      verbose?
    end

    def default_for_add_preamble
      verbose?
    end

    def default_for_exception_on_error
      true
    end

    # Actual tasks on the barista module.

    def compile_as(file, type)
      origin_path, framework = Framework.full_path_for(file)
      return if origin_path.nil?
      if type == :coffeescript
        return File.read(origin_path), File.mtime(origin_path)
      else
        return compile_file!(file), Time.now
      end
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
      Barista.invoke_hook :before_full_compilation
      Framework.exposed_coffeescripts.each do |coffeescript|
        compile_file! coffeescript, force, silence_error
      end
      Barista.invoke_hook :all_compiled
      true
    end

    def change_output_prefix!(framework, prefix = nil)
      framework = framework.is_a?(Barista::Framework) ? framework : Barista::Framework[framework]
      framework.output_prefix = prefix if framework.present?
    end

    def each_framework(include_default = false)
      Framework.all(include_default).each { |f| yield f if block_given? }
    end

    def output_path_for(file)
      output_root.join(file.to_s.gsub(/^\/+/, '')).to_s.gsub(/\.coffee$/, '.js')
    end

    def debug(message)
      logger.debug "[Barista] #{message}"
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
