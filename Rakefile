require 'rubygems'
require 'rake'

require 'lib/barista/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "barista"
    gem.summary     = %Q{Simple, transparent coffeescript integration for Rails and Rack applications.}
    gem.description = File.read(File.expand_path('DESCRIPTION', File.dirname(__FILE__)))
    gem.email       = "sutto@sutto.net"
    gem.homepage    = "http://github.com/Sutto/barista"
    gem.version     = Barista::Version::STRING
    gem.authors     = ["Darcy Laycock"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = Barista::Version::STRING
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "barista #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
