source "https://rubygems.org"

# Specify your gem's dependencies in event_engine-delivery.gemspec.
gemspec

# The core gem this delivery layer builds on. Use the local checkout when it's
# present (development); fall back to the GitHub source on CI, where the sibling
# repo isn't checked out.
event_engine_path = File.expand_path("../event_engine", __dir__)
if File.directory?(event_engine_path)
  gem "event_engine", path: event_engine_path
else
  gem "event_engine", github: "tylercschneider/event_engine"
end

gem "puma"

gem "sqlite3"

gem "propshaft"

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
