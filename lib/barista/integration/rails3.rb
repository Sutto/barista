module Barista
  module Integration
    module Rails3    
      class Railtie < Rails::Railtie
        
        rake_tasks do
          load Barista.library_root.join('barista/tasks/barista.rake').to_s
        end

        initializer 'barista.wrap_filter' do
          config.app_middleware.use Barista::Filter if Barista.add_filter?
          config.app_middleware.use Barista::Server::Proxy
        end

        initializer 'barista.defaults' do
          Barista.setup_defaults
        end

        initializer 'barista.helpers' do
          ActionController::Base.helper Barista::Helpers
        end
        
      end
    end
  end
end