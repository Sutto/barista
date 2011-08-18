require 'rubygems'

ENV['RAILS_ENV'] ||= 'test'

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"

require 'rspec/rails'

Bundler.require(:default, Rails.env) if defined?(Bundler)

require 'barista'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end

