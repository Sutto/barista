ENV['RAILS_ENV'] ||= 'test'

require 'bundler/setup'

spec_dir = Rails.root.join("spec")

Dir[spec_dir.join("support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rr
end