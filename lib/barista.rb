require 'active_support'
require 'pathname'

module Barista
  
  autoload :Compiler, 'barista/compiler'
  
  class << self
    
    def root
      @root ||= Rails.root.join("app", "scripts")
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
    rescue SysCallError
      nil
    end
    
    def compile_file!(file)
      file = file.to_s
      file = root.join(file).to_s unless file.include?(root.to_s)
      destination_path = file.gsub(/\.(coffee|js)\Z/, '') + ".js"
      return unless should_compile_file?(file, destination_path)
      File.open(destination_path, "w+") do |f|
        f.write Compiler.compile(File.read(file))
      end
      true
    rescue SysCallError
      false
    end
    
    def should_compile_file?(from, to)
      File.exist?(from) && (!File.exist?(to) || File.mtime(to) < File.mtime(from))
    end
    
    def compile_all!
      Dir[root.join("**", "*.coffee")].each {|file| compile_file! file }
    end
    
  end
  
  if defined?(Rails::Engine)
    class Engine < Rails::Engine; end
  end
  
end