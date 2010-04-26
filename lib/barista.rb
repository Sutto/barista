require 'active_support'
require 'pathname'

module Barista
  
  autoload :Compiler, 'barista/compiler'
  autoload :Filter,   'barista/filter' 
  
  class << self
    
    def configure
      yield self if block_given?
    end
    
    def root
      @root ||= Rails.root.join("app", "coffeescripts")
    end
    
    def root=(value)
      @root = Pathname(value.to_s)
    end
    
    def output_root
      @output_root ||= Rails.root.join("public", "javascripts")
    end
    
    def output_root=(value)
      @output_root = Pathname(value.to_s)
    end
    
    def render_path(path)
      full_path = root.join("#{path.gsub(/(\A\/|\/\Z)/, '')}.coffee")
      return unless full_path.exist? && full_path.readable?
      Compiler.compile(full_path.read)
    rescue SystemCallError
      nil
    end
    
    def compile_file!(file, force = false)
      file = file.to_s
      file = root.join(file).to_s unless file.include?(root.to_s)
      destination_path = file.gsub(/\.(coffee|js)\Z/, '').gsub(root.to_s, output_root.to_s) + ".js"
      return unless force || should_compile_file?(file, destination_path)
      Rails.logger.debug "[Barista] Compiling #{file} to #{destination_path}"
      FileUtils.mkdir_p File.dirname(destination_path)
      File.open(destination_path, "w+") do |f|
        f.write Compiler.compile(File.read(file))
      end
      true
    rescue SystemCallError
      false
    end
    
    def should_compile_file?(from, to)
      File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
    end
    
    def compile_all!(force = false)
      Dir[root.join("**", "*.coffee")].each {|file| compile_file! file, force }
      true
    end
    
    # By default, only add it in dev / test
    def add_filter?
      Rails.env.test? || Rails.env.development?
    end
    
    def no_wrap?
      defined?(@no_wrap) && @no_wrap
    end
    
    def no_wrap!
      self.no_wrap = false
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