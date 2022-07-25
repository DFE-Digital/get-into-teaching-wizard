# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_wizard/version"

Gem::Specification.new do |gem|
  gem.name = "git_wizard"
  gem.version = GITWizard::VERSION
  gem.summary = "Abstract classes for building a wizard"
  gem.description = <<~DESCRIPTION
    Abstract classes to simplify building a linear wizard with conditional
    steps from ActiveModel objects
  DESCRIPTION
  gem.authors = ["Jeremy Wilkins", "Joseph Kempster"]
  gem.email = %w[jeremy.wilkins@digital.education.gov.uk joseph.kempster@education.gov.uk]
  gem.homepage = "https://github.com/DFE-Digital/git_wizard"
  gem.license = "MIT"

  gem.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = %w[lib]
  gem.required_ruby_version = ">= 2.6.0"

  gem.add_dependency "activemodel", ">= 6.0.3.4"
  gem.add_dependency "activesupport", ">= 6.0.3.4"

  gem.add_development_dependency "bundler"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "rails", "~> 6.1.4", ">= 6.1.4.1"
  gem.add_development_dependency "rails-controller-testing"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", ">= 3.10.0"
  gem.add_development_dependency "rspec-rails"
  gem.add_development_dependency "rubocop-govuk", "3.17.2"
  gem.add_development_dependency "simplecov", ">= 0.19.1"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "webrick"
  gem.add_development_dependency "yard"
end
