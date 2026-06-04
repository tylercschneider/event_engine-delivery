require "test_helper"

module EventEngine
  module Cloud
    class BatchTest < ActiveSupport::TestCase
      setup do
        @batch = Batch.new(max_size: 3)
      end

      test "push adds entry and returns size" do
        size = @batch.push({ event_id: 1 })
        assert_equal 1, size
      end

      test "drain returns all entries and empties batch" do
        @batch.push({ event_id: 1 })
        @batch.push({ event_id: 2 })

        entries = @batch.drain

        assert_equal 2, entries.size
        assert_equal({ event_id: 1 }, entries[0])
        assert_equal({ event_id: 2 }, entries[1])
        assert_equal 0, @batch.size
      end

      test "full? returns true when max_size reached" do
        @batch.push({ event_id: 1 })
        @batch.push({ event_id: 2 })
        refute @batch.full?

        @batch.push({ event_id: 3 })
        assert @batch.full?
      end

      test "size returns current entry count" do
        assert_equal 0, @batch.size

        @batch.push({ event_id: 1 })
        assert_equal 1, @batch.size
      end

      test "thread safety under concurrent pushes" do
        batch = Batch.new(max_size: 1000)
        threads = 10.times.map do |i|
          Thread.new do
            100.times { |j| batch.push({ event_id: (i * 100) + j }) }
          end
        end
        threads.each(&:join)

        entries = batch.drain
        assert_equal 1000, entries.size
      end
    end
  end
end
