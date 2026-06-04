require "test_helper"

module EventEngine
  class LockingStrategyTest < ActiveSupport::TestCase
    test "NullStrategy returns scope unchanged" do
      scope = OutboxEvent.unpublished
      strategy = LockingStrategy::NullStrategy.new

      result = strategy.apply(scope)

      assert_equal scope.to_sql, result.to_sql
    end

    test "PostgresStrategy applies FOR UPDATE SKIP LOCKED" do
      scope = OutboxEvent.unpublished
      strategy = LockingStrategy::PostgresStrategy.new

      result = strategy.apply(scope)

      assert_equal "FOR UPDATE SKIP LOCKED", result.lock_value
    end

    test "for_current_adapter returns NullStrategy for SQLite" do
      strategy = LockingStrategy.for_current_adapter

      assert_instance_of LockingStrategy::NullStrategy, strategy
    end
  end
end
