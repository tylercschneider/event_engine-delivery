# Changelog

All notable changes to this project are documented here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial gem scaffold: mountable `EventEngine::Delivery` Rails engine depending on
  `event_engine`.
- Verbatim copy of `event_engine` as the starting point for the delivery layer
  (standalone, depends only on Rails); full suite green. Inherited RuboCop offenses
  grandfathered in `.rubocop_todo.yml` so the lint gate still checks new code.
