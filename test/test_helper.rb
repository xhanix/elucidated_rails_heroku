ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'
require 'stripe_mock'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  setup do
    DatabaseCleaner.start
    StripeMock.start
end
teardown do
    DatabaseCleaner.clean
    StripeMock.stop
end
  # Add more helper methods to be used by all tests here...
end

require 'mocha/setup'