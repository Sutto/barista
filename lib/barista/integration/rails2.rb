module Barista
  module Integration
    module Rails2
      
      def self.setup
        ActionController::Dispatcher.middleware.tap do |middleware|
          middleware.use Barista::Filter if Barista.add_filter?
          middleware.use Barista::Server::Proxy
        end
        Barista.setup_defaults
        ActionController::Base.helper Barista::Helpers
      end
      
    end
  end
end