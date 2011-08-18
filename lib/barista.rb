require 'pathname'
require 'time' # Required for httpdate
require 'coffee_script'

# Setup ExecJS extras if present
if defined?(ExecJS::ExternalRuntime)
  ExecJS::ExternalRuntime.send :attr_accessor, :binary
end

module Barista

  Error                    = Class.new(StandardError)
  CompilationError         = Class.new(Error)
  CompilerUnavailableError = Class.new(Error)

  autoload :Compiler,    'barista/compiler'
  autoload :Extensions,  'barista/extensions'
  autoload :Filter,      'barista/filter'
  autoload :Framework,   'barista/framework'
  autoload :HamlFilter,  'barista/haml_filter'
  autoload :Helpers,     'barista/helpers'
  autoload :Hooks,       'barista/hooks'
  autoload :Integration, 'barista/integration'
  autoload :Server,      'barista/server'

  class << self
    include Extensions

    def library_root
      @library_root ||= Pathname(__FILE__).dirname
    end

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
    
    def has_hook?(name)
      hooks.has_hook?(name)
    end

    has_hook_method :on_compilation_error        => :compilation_failed,
                    :on_compilation              => :compiled,
                    :on_compilation_complete     => :all_compiled,
                    :on_compilation_with_warning => :compiled_with_warning,
                    :before_full_compilation     => :before_full_compilation,
                    :before_compilation          => :before_compilation

    # Configuration - Tweak how you use Barista.

    has_boolean_options    :verbose, :bare, :add_filter, :add_preamble, :exception_on_error, :embedded_interpreter, :auto_compile
    has_delegate_methods   Compiler, :bin_path, :bin_path=, :js_path, :js_path=
    has_delegate_methods   Framework, :register
    has_deprecated_methods :compiler, :compiler=, :compiler_klass, :compiler_klass=

    def add_preamble(&blk)
      self.add_preamble = true
      if block_given?
        @preamble = blk
      end
    end
    
    def preamble
      @preamble
    end
    
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

    # Default configuration options

    def local_env?
      %w(test development).include? Barista.env
    end

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
      local_env?
    end

    def default_for_add_filter
      local_env?
    end

    def default_for_exception_on_error
      true
    end

    def default_for_embedded_interpreter
      false
    end

    def default_for_auto_compile
      true
    end


    # Actual tasks on the barista module.

    def compile_file!(file, force = false, silence_error = false)
      Compiler.autocompile_file file, force, silence_error
    end

    def compile_all!(force = false, silence_error = true)
      debug "Compiling all coffeescripts" if Barista.auto_compile?
      Barista.invoke_hook :before_full_compilation
      Framework.exposed_coffeescripts.each do |coffeescript|
        Compiler.autocompile_file coffeescript, force, silence_error
      end
      debug "Copying all javascripts"
      Framework.exposed_javascripts.each do |javascript|
        Compiler.autocompile_file javascript, force, silence_error
      end
      Barista.invoke_hook :all_compiled
      true
    end

    def change_output_prefix!(framework, prefix = nil)
      framework = Barista::Framework[framework] unless framework.is_a?(Barista::Framework)
      framework.output_prefix = prefix if framework
    end

    def change_output_root!(framework, root)
      framework = Barista::Framework[framework] unless framework.is_a?(Barista::Framework)
      framework.output_root = root if framework
    end

    def each_framework(include_default = false, &blk)
      Framework.all(include_default).each(&blk)
    end

    def output_path_for(file)
      output_root.join(file.to_s.gsub(/^\/+/, '')).to_s.gsub(/\.coffee$/, '.js')
    end

    def debug(message)
      logger.debug "[Barista] #{message}" if logger
    end

    def setup_defaults
      Barista::HamlFilter.setup
      Barista::Compiler.setup_default_error_logger
    end

  end

  # Setup integration by default.
  Integration.setup

end
