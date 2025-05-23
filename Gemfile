# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'devise'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'httparty'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.4'
gem 'ransack'
gem 'sprockets-rails'
gem 'sqlite3', '~> 1.4'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :production do
  gem 'airbrake-ruby'
end

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem 'airbrake', '~> 13.0'
gem 'http', '~> 5.1'       # For HTTP requests
gem 'nokogiri', '~> 1.14'  # For HTML parsing
gem 'activerecord-nulldb-adapter', group: :production
