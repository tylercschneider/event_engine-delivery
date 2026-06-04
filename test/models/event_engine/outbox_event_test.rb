require "test_helper"

module EventEngine
  class OutboxEventTest < ActiveSupport::TestCase
    # validations
    test "persists an outbox event" do
      event = OutboxEvent.create!(
        event_name: "example.event",
        event_type: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      assert event.persisted?
    end

    test "outbox event is invalid without event_name" do
      event = OutboxEvent.new(event_type: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "outbox event is invalid without event_type" do
      event = OutboxEvent.new(event_name: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "outbox event is invalid without payload" do
      event = OutboxEvent.new(event_name: "example.event", event_type: "example.event", event_version: 1)

      assert_not event.valid?
    end

    test "duplicate idempotency_key is rejected" do
      OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        idempotency_key: "abc-123"
      )

      duplicate = OutboxEvent.new(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "b" },
        idempotency_key: "abc-123"
      )

      assert_not duplicate.valid?
    end

    # lifecycle
    test "outbox event is unpublished by default" do
      event = OutboxEvent.create!(
        event_type: "example.event",
        event_name: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      assert_nil event.published_at
    end

    test "mark_published! sets published_at" do
      event = OutboxEvent.create!(
        event_type: "example.event",
        event_name: "example.event",
        event_version: 1,
        occurred_at: Time.current,
        payload: {filler: "dummy"}
      )

      event.mark_published!

      assert_not_nil event.published_at
    end

    # idempotency
    test "duplicate idempotency_key raises at the database level" do
      OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        idempotency_key: "abc-123"
      )

      assert_raises ActiveRecord::RecordNotUnique do
        OutboxEvent.new(
          event_type: "OrderCreated",
          event_name: "order.created",
          event_version: 1,
          occurred_at: Time.current,
          payload: { filler: "b" },
          idempotency_key: "abc-123"
        ).save!(validate: false)
      end
    end

    # querying
    test "unpublished scope returns only unpublished events" do
      published = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        published_at: Time.current
      )

      unpublished = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "y" }
      )

      assert_equal [unpublished], OutboxEvent.unpublished.to_a
    end

    test "unpublished events are ordered by created_at ascending" do
      older = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" }
      )

      travel 1.second

      newer = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "b" }
      )

      assert_equal [older, newer], OutboxEvent.unpublished.ordered.to_a
    end

    # cleanup scopes
    test "published_before scope returns events published before given time" do
      old_event = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: 40.days.ago,
        payload: { filler: "old" },
        published_at: 40.days.ago
      )

      recent_event = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: 5.days.ago,
        payload: { filler: "recent" },
        published_at: 5.days.ago,
        idempotency_key: SecureRandom.uuid
      )

      cutoff = 30.days.ago
      assert_includes OutboxEvent.published_before(cutoff), old_event
      assert_not_includes OutboxEvent.published_before(cutoff), recent_event
    end

    test "cleanable scope excludes unpublished and dead-lettered events" do
      published = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        published_at: 40.days.ago
      )

      unpublished = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "b" },
        idempotency_key: SecureRandom.uuid
      )

      dead_lettered = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "c" },
        published_at: 40.days.ago,
        dead_lettered_at: Time.current,
        idempotency_key: SecureRandom.uuid
      )

      cleanable = OutboxEvent.cleanable
      assert_includes cleanable, published
      assert_not_includes cleanable, unpublished
      assert_not_includes cleanable, dead_lettered
    end

    # dead letter recovery
    test "retry! resets attempts and clears dead_lettered_at" do
      event = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        attempts: 5,
        dead_lettered_at: Time.current
      )

      assert event.dead_lettered?

      event.retry!

      assert_equal 0, event.attempts
      assert_nil event.dead_lettered_at
      assert_not event.dead_lettered?
    end

    test "retry! clears error context" do
      event = OutboxEvent.create!(
        event_type: "OrderCreated",
        event_name: "order.created",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "a" },
        attempts: 5,
        dead_lettered_at: Time.current,
        last_error_message: "connection reset",
        last_error_class: "RuntimeError"
      )

      event.retry!

      assert_nil event.last_error_message
      assert_nil event.last_error_class
    end
  end
end
