require 'rubygems'
require 'rake'

require 'lib/barista/version'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = "barista"
    gem.summary     = %Q{Transparent coffeescript support for rails 3.}
    gem.description = %Q{Automatically compiles app/coffeescripts/*.coffee to javascript for rails and rack awesomesauce.}
    gem.email       = "sutto@sutto.net"
    gem.homepage    = "http://github.com/Sutto/barista"
    gem.version     = Barista::Version::STRING
    gem.authors     = ["Darcy Laycock"]
    gem.add_dependency 'coffee-script', '~> 2.1'
    
    gem.add_development_dependency 'rspec', '~> 2.0.0.beta.22'
    gem.add_development_dependency 'rr', '~> 1.0'
    
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "barista #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
