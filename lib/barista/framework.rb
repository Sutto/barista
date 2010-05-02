module Barista
  class Framework
    
    def self.default_framework
      @default_framework ||= self.new("default", Barista.root)
    end
    
    def self.default_framework=(value)
      @default_framework = value
    end
    
    def self.all
      [default_framework] + (@all ||= [])
    end
    
    def self.exposed_coffeescripts
      all.inject([]) do |collection, fw|
        collection + fw.exposed_coffeescripts
      end.uniq
    end
    
    def self.full_path_for(script)
      script = script.to_s.gsub(/\.js$/, '.coffee').gsub(/^\/+/, '')
      all.each do |fw|
        full_path = fw.full_path_for(script)
        return full_path, fw if full_path
      end
      nil
    end
    
    def self.register(name, root)
      (@all ||= []) << self.new(name, root)
    end
    
    attr_reader :name, :framework_root
    
    def initialize(name, root)
      @name           = name
      @framework_root = File.expand_path(root)
    end
    
    def coffeescripts
      Dir[File.join(@framework_root, "**", "*.coffee")]
    end
    
    def short_name(script)
      File.expand_path(script).gsub /^#{Regexp.escape(@framework_root)}\/?/, ''
    end
    
    def exposed_coffeescripts
      coffeescripts.map { |script| short_name(script) }
    end
    
    def full_path_for(name)
      full_path = File.join(@framework_root, name)
      File.exist?(full_path) ? full_path : nil
    end
    
  end
end