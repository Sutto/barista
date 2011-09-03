require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end

require 'rake'
require 'rspec/core/rake_task'

require 'barista/version'

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

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = Barista::Version::STRING
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "barista #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :spec

require 'barista'


