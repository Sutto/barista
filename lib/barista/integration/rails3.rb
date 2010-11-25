module Barista
  module Integration
    module Rails3    
      class Railtie < Rails::Railtie
        
        rake_tasks do
          load Barista.library_root.join('barista/tasks/barista.rake').to_s
        end

        initializer 'barista.wrap_filter' do
          config.app_middleware.use Barista::Filter if Barista.add_filter?
        end

        initializer 'barista.error_messages' do
          Barista::Compiler.setup_default_error_logger!
        end

        initializer 'barista.haml_filter' do
          Barista::HamlFilter.setup!
        end

        initializer 'barista.helpers' do
          ActionController::Base.helper Barista::Helpers
        end
        
        initializer 'barista.routing' do
          Rails.application.routes.draw do
            server = Barista::Server.new
            match 'javascripts/*js.js',       :to => server
            match 'coffeescripts/*js.coffee', :to => server if Barista.embedded_interpreter?
          end
        end
        
      end
    end
  end
end