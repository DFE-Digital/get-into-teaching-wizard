# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gemspec

gem "get_into_teaching_api_client_faraday", github: "DFE-Digital/get-into-teaching-api-ruby-client", require: "api/client"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

group :test do
    gem 'shoulda-matchers', '~> 5.0'
end
