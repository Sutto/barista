module Barista
  class Framework

    def self.default_framework
      @default_framework ||= self.new("default", Barista.root)
    end

    def self.default_framework=(value)
      @default_framework = value
    end

    def self.all(include_default = false)
      all = (@all ||= [])
      all = [default_framework] + all if include_default
      all
    end

    def self.exposed_coffeescripts
      all(true).inject([]) do |collection, fw|
        collection + fw.exposed_coffeescripts
      end.uniq.sort_by { |f| f.length }
    end

    def self.full_path_for(script)
      script = script.to_s.gsub(/\.js$/, '.coffee').gsub(/^\/+/, '')
      all(true).each do |fw|
        full_path = fw.full_path_for(script)
        return full_path, fw if full_path
      end
      nil
    end

    def self.register(name, root)
      (@all ||= []) << self.new(name, root)
    end

    def self.[](name)
      name = name.to_s
      (@all ||= []).detect { |fw| fw.name == name }
    end

    attr_reader :name, :framework_root, :output_prefix

    def initialize(name, root, output_prefix = nil)
      @name           = name.to_s
      @output_prefix  = nil
      @framework_root = File.expand_path(root)
    end

    def coffeescripts
      Dir[File.join(@framework_root, "**", "*.coffee")]
    end

    def short_name(script)
      short_name = remove_prefix script, @framework_root
      File.join *[@output_prefix, short_name].compact
    end

    def exposed_coffeescripts
      coffeescripts.map { |script| short_name(script) }
    end

    def output_prefix=(value)
      value = value.to_s.gsub /(^\/|\/$)/, ''
      @output_prefix = value.blank? ? nil : value
    end

    def full_path_for(name)
      full_path = File.join(@framework_root, remove_prefix(name, @output_prefix.to_s))
      File.exist?(full_path) ? full_path : nil
    end

    protected

    def remove_prefix(path, prefix)
      path.to_s.gsub /^#{Regexp.escape(prefix.to_s)}\/?/, ''
    end

  end
end
