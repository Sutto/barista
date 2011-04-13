module Barista
  module Integration

    autoload :Rails2,  'barista/integration/rails2'
    autoload :Rails3,  'barista/integration/rails3'
    autoload :Sinatra, 'barista/integration/sinatra'

    def self.setup
      setup_rails   if defined?(Rails)
    end

    def self.setup_rails
      case Rails::VERSION::MAJOR
      when 3
        Rails3
      when 2
        # We need to manually call the initialiser stuff in Rails 2.
        Rails2.setup
      end
    end

  end
end