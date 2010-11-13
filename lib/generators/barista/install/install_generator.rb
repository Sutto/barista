module Barista
  module Generators
    class InstallGenerator < Rails::Generators::Base
  
      source_root File.expand_path("templates", File.dirname(__FILE__))
  
      def create_initializer
        copy_file 'initializer.rb', 'config/initializers/barista_config.rb'
      end
  
    end
  end
end