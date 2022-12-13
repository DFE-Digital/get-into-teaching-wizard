require "simplecov"
SimpleCov.start do
  add_filter "/spec/dummy"
end

ENV["RAILS_ENV"] ||= "test"

require "rails/all"
require "rspec/expectations"
require "rails-controller-testing"
require "dummy/config/environment"
require "shoulda/matchers"

Dir["#{Dir.getwd}/spec/support/**/*.rb"].sort.each { |f| require f }

require "spec_helper"

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_model
  end
end
