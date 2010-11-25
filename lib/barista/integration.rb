module Barista
  module Integration
    
    autoload :Rails3,  'barista/integration/rails3'
    autoload :Sinatra, 'barista/integration/sinatra'
    
    def self.setup
      setup_rails   if defined?(Rails)
      setup_sinatra if defined?(::Sinatra)
    end
    
    def self.setup_rails
      case Rails::VERSION::MAJOR
      when 3
        require 'barista/integration/rails3'
      end
    end
    
    def self.setup_sinatra
      ::Sinatra::Base.register(Sinatra)
    end
    
  end
end