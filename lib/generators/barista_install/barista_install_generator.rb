class BaristaInstallGenerator < Rails::Generators::Base
  
  def self.source_root
    @_ps_source_root ||= File.expand_path("templates", File.dirname(__FILE__))
  end
  
  def create_initializer
    copy_file 'initializer.rb', 'config/initializers/barista_config.rb'
  end
  
end