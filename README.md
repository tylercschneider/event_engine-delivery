# EventEngine::Delivery

The delivery layer for [EventEngine](https://github.com/tylercschneider/event_engine).

`event_engine` is the foundation — it declares events with a schema-first DSL and
compiles them to a canonical schema. `event_engine-delivery` takes an emitted event
and gets it delivered reliably: the durability **level ladder (0–4)**, the
transactional **outbox**, retry, **dead-letter** handling, pluggable **transports**,
the observability dashboard, and the cloud reporter.

Apps that only need to *declare* events depend on `event_engine` alone. Apps that need
durable delivery add this gem on top.

## Installation

```ruby
gem "event_engine"
gem "event_engine-delivery"
```

```bash
$ bundle
```

## Status

Early extraction from `event_engine`. The delivery code moves over one cohesive unit
at a time: transports → outbox → emit path → dashboard/cloud → configuration.

## License

Available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
