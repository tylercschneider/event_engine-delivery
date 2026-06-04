source "https://rubygems.org"

# Specify your gem's dependencies in event_engine-delivery.gemspec.
gemspec

# The core gem this delivery layer builds on. Pathed for local development;
# consumers depend on it via the published/github gem.
gem "event_engine", path: "../event_engine"

gem "puma"

gem "sqlite3"

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
