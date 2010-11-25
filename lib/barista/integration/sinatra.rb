module Barista
  module Integration
    module Sinatra
      
      def self.registered(app)
        app.configure do |inner_app|
          setup_defaults! inner_app
          inner_app.use Barista::Filter if Barista.add_filter?
        end
        
        # Setup a virtual application.
        server = Barista::Server.new
        
        # Map to the javascripts route.
        app.get '/javascripts/*.js' do
          server.call env
        end
        
        # And the coffee script route.
        app.get '/coffeescripts/*.coffee' do
          server.call env
        end if Barista.embedded_interpreter?
        
      end
      
      def self.setup_defaults!(app)
        Barista.configure do |c|
          c.env         = app.environment.to_s
          c.app_root    = app.root.to_s
          c.output_root = File.join(app.public.to_s, 'javascripts')
        end
      end
      
    end
  end
end