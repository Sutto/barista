require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'
ENV['RAILS_ROOT'] ||= File.expand_path("..", __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

require 'rspec/rails'

Bundler.require(:default, Rails.env) if defined?(Bundler)

class Application < Rails::Application; end

require 'barista'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end

