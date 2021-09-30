ENV["RAILS_ENV"] ||= "test"

require "rails/all"
require "rspec/expectations"
require "rails-controller-testing"
require "dummy/config/environment"
require "shoulda/matchers"

require "spec_helper"
