module Barista
  module Integration
    module Sinatra

      def self.registered(app)
        app.configure do |inner_app|
          setup_defaults inner_app
          inner_app.use Barista::Filter if Barista.add_filter?
          inner_app.use Barista::Server::Proxy
          Barista.setup_defaults
        end

      end

      def self.setup_defaults(app)
        Barista.configure do |c|
          c.env = app.environment.to_s
        end
      end

    end
  end
end