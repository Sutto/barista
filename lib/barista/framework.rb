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
      all.detect { |fw| fw.full_path_for(script) }
    end
    
    def register(name, folder)
      (@all ||= []) << self.new(name, folder)
    end
    
    def initialize(name, folder)
      @name             = name
      @framework_folder = File.expand_path(folder)
    end
    
    def coffeescripts
      Dir[File.join(@framework_folder, "**", "*.coffee")]
    end
    
    def short_name(script)
      File.expand_path(script).gsub /^#{Regexp.escape(@folder)}\/?/, ''
    end
    
    def exposed_coffeescripts
      coffeescripts.map { |script| short_name(script) }
    end
    
    def full_path_for(name)
      full_path = File.join(@framework_folder, name)
      File.exist?(full_path) ? full_path : nil
    end
    
  end
end