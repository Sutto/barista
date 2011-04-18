module Barista
  class Framework

    def self.default_framework
      @default_framework ||= self.new(:name => "default", :root => Barista.root)
    end

    def self.default_framework=(value)
      @default_framework = value
    end

    def self.all(include_default = false)
      (@all ||= []).dup.tap do |all|
        all.unshift default_framework if include_default
      end
    end

    def self.exposed_coffeescripts
      all(true).inject([]) do |collection, fw|
        collection + fw.exposed_coffeescripts
      end.uniq.sort_by { |f| f.length }
    end

    def self.exposed_javascripts
      all(true).inject([]) do |collection, fw|
        collection + fw.exposed_javascripts
      end.uniq.sort_by { |f| f.length }
    end

    def self.coffeescript_glob_paths
      all(true).map { |fw| fw.coffeescript_glob_path }
    end

    def self.full_path_for(script)
      javascript   = script.to_s.gsub(/\.coffee$/, '.js').gsub(/^\/+/, '')
      coffeescript = script.to_s.gsub(/\.js$/, '.coffee').gsub(/^\/+/, '')
      all(true).each do |fw|
        full_path = fw.full_path_for(coffeescript) || fw.full_path_for(javascript)
        return full_path, fw if full_path
      end
      nil
    end

    def self.register(name, options = nil)
      if options.is_a?(Hash)
        framework = self.new(options.merge(:name => name))
      else
        framework = self.new(:name => name, :root => options)
      end
      (@all ||= []) << framework
    end

    def self.[](name)
      name = name.to_s
      (@all ||= []).detect { |fw| fw.name == name }
    end

    attr_reader :name, :framework_root, :output_prefix

    def initialize(options, root = nil, output_prefix = nil)
      unless options.is_a?(Hash)
        Barista.deprecate! self, "initialize(name, root = nil, output_prefix = nil)", "Please use the option syntax instead."
        options = {
          :name          => options,
          :root          => root,
          :output_prefix => output_prefix
        }
      end
      # actually setup the framework.
      check_options! options, :name, :root
      @name            = options[:name].to_s
      @output_prefix   = options[:output_prefix]
      @framework_root  = File.expand_path(options[:root].to_s)
      self.output_root = options[:output_root]
    end

    def coffeescripts
      Dir[coffeescript_glob_path]
    end

    def javascripts
      Dir[javascript_glob_path]
    end

    def coffeescript_glob_path
      @coffeescript_glob_path ||= File.join(@framework_root, "**", "*.coffee")
    end

    def javascript_glob_path
      @javascript_glob_path ||= File.join(@framework_root, "**", "*.js")
    end

    def short_name(script)
      short_name = remove_prefix script, @framework_root
      File.join(*[@output_prefix, short_name].compact)
    end

    def exposed_coffeescripts
      coffeescripts.map { |script| short_name(script) }
    end

    def exposed_javascripts
      javascripts.map { |script| short_name(script) }
    end

    def output_prefix=(value)
      value = value.to_s.gsub(/(^\/|\/$)/, '').strip
      @output_prefix = value.empty? ? nil : value
    end

    def full_path_for(name)
      full_path = File.join(@framework_root, remove_prefix(name, @output_prefix.to_s))
      File.exist?(full_path) ? full_path : nil
    end

    def output_root
      @output_root || Barista.output_root
    end

    def output_root=(value)
      if value.nil?
        @output_root = nil
      else
        @output_root = Pathname(value.to_s)
      end
    end

    def output_path_for(file, format = 'js')
      # Strip the leading slashes
      file = file.to_s.gsub(/^\/+/, '')
      output_root.join(file).to_s.gsub(/\.[^\.]+$/, ".#{format}")
    end

    protected

    def remove_prefix(path, prefix)
      path.to_s.gsub(/^#{Regexp.escape(prefix.to_s)}\/?/, '')
    end

    def check_options!(options, *keys)
      keys.each do |option|
        raise ArgumentError, "#{option.inspect} is a required options." if options[option].nil?
      end
    end

  end
end
