module EventEngine
  module Cloud
    # Thread-safe accumulator for Cloud Reporter entries.
    # Entries are pushed individually and drained in bulk for flushing.
    class Batch
      # @param max_size [Integer] triggers auto-flush when reached
      def initialize(max_size:)
        @max_size = max_size
        @entries = []
        @mutex = Mutex.new
      end

      # Adds an entry to the batch.
      #
      # @param entry [Hash] serialized event metadata
      # @return [Integer] current batch size after push
      def push(entry)
        @mutex.synchronize do
          @entries << entry
          @entries.size
        end
      end

      # Removes and returns all entries, emptying the batch.
      #
      # @return [Array<Hash>]
      def drain
        @mutex.synchronize do
          entries = @entries.dup
          @entries.clear
          entries
        end
      end

      # Whether the batch has reached its max size.
      #
      # @return [Boolean]
      def full?
        @mutex.synchronize { @entries.size >= @max_size }
      end

      # Returns the current number of entries.
      #
      # @return [Integer]
      def size
        @mutex.synchronize { @entries.size }
      end
    end
  end
end
