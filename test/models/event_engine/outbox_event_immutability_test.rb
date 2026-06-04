require "test_helper"

module EventEngine
  class OutboxEventImmutabilityTest < ActiveSupport::TestCase
    setup do
      @event = OutboxEvent.create!(
        event_name: "order.created",
        event_type: "domain",
        event_version: 1,
        occurred_at: Time.current,
        payload: { filler: "x" },
        metadata: { source: "test" },
        idempotency_key: "key-123"
      )
    end

    test "event_name is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(event_name: "changed")
      end
    end

    test "event_type is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(event_type: "changed")
      end
    end

    test "event_version is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(event_version: 99)
      end
    end

    test "payload is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(payload: { changed: true })
      end
    end

    test "metadata is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(metadata: { changed: true })
      end
    end

    test "occurred_at is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(occurred_at: 1.year.ago)
      end
    end

    test "idempotency_key is readonly after create" do
      assert_raises ActiveRecord::ReadonlyAttributeError do
        @event.update!(idempotency_key: "changed")
      end
    end

    test "published_at remains mutable" do
      @event.update!(published_at: Time.current)
      assert_not_nil @event.reload.published_at
    end

    test "attempts remains mutable" do
      @event.update!(attempts: 3)
      assert_equal 3, @event.reload.attempts
    end

    test "dead_lettered_at remains mutable" do
      @event.update!(dead_lettered_at: Time.current)
      assert_not_nil @event.reload.dead_lettered_at
    end
  end
end
