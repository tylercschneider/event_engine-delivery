source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in event_engine-delivery.gemspec.
gemspec

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

group :development, :test do
  # Needed for the dummy app database
  gem "sqlite3"
  gem "sprockets-rails"
  gem "pry"
  gem "pry-byebug"
  gem "minitest", "~> 5.0"  # pin to 5.x; minitest 6 removed minitest/mock
  gem "minitest-reporters"
  gem "minitest-focus"
  gem "diffy"
  gem "webmock"
end
