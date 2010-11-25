module Barista
  module Integration
   
    autoload :Rails3,  'barista/integration/rails3'
    autoload :Sinatra, 'barista/integration/sinatra'
   
    def self.setup
      if defined?(Rails)
        setup_rails
      end
      ::Sinatra::Base.register(Sinatra) if defined?(::Sinatra)
    end
   
  end
end