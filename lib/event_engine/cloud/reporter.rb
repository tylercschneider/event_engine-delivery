module EventEngine
  module Cloud
    # Singleton that collects event metadata and sends it to EventEngine Cloud.
    # Manages the full lifecycle: start, collect via {Subscribers}, batch, flush, shutdown.
    #
    # Activated automatically at boot when +cloud_api_key+ is configured.
    # All errors are rescued — reporter failures never affect the host application.
    class Reporter
      class << self
        # Returns the singleton instance.
        #
        # @return [Reporter]
        def instance
          @instance ||= new
        end

        # Resets the singleton, discarding state without flushing.
        #
        # @return [void]
        def reset!
          if @instance
            @instance.instance_variable_set(:@running, false)
            timer = @instance.instance_variable_get(:@timer_thread)
            timer&.kill
            @instance = nil
          end
        end
      end

      def initialize
        @running = false
        @batch = nil
        @client = nil
        @mutex = Mutex.new
        @timer_thread = nil
      end

      # Initializes the batch and API client, begins accepting entries.
      #
      # @return [void]
      def start
        config = EventEngine.configuration
        @batch = Batch.new(max_size: config.cloud_batch_size)
        @client = ApiClient.new(
          api_key: config.cloud_api_key,
          endpoint: config.cloud_endpoint
        )
        @running = true
        @flush_interval = config.cloud_flush_interval
        start_timer

        logger.info("[EventEngine] Cloud Reporter started — reporting to #{config.cloud_endpoint}")
      end

      # Flushes remaining entries and stops the reporter.
      #
      # @return [void]
      def shutdown
        return unless @running

        @running = false
        stop_timer
        flush

        logger.info("[EventEngine] Cloud Reporter stopped")
      end

      # Whether the reporter is currently active.
      #
      # @return [Boolean]
      def running?
        @running
      end

      # Records an emitted event entry.
      # @param entry [Hash] serialized event metadata
      # @return [void]
      def track_emit(entry)
        push(entry)
      end

      # Records a published event entry.
      # @param entry [Hash] serialized event metadata
      # @return [void]
      def track_publish(entry)
        push(entry)
      end

      # Records a dead-lettered event entry.
      # @param entry [Hash] serialized event metadata
      # @return [void]
      def track_dead_letter(entry)
        push(entry)
      end

      # Drains the batch and sends entries to the Cloud API.
      # Does nothing if the batch is empty. Errors are logged, never raised.
      #
      # @return [void]
      def flush
        return unless @batch

        entries = @batch.drain
        return if entries.empty?

        @client.send_batch(entries)
      rescue StandardError => e
        EventEngine.configuration.logger.error(
          "[EventEngine::Cloud] Flush failed: #{e.class} - #{e.message}"
        )
      end

      # Returns the number of entries currently queued.
      #
      # @return [Integer]
      def batch_size
        @batch&.size || 0
      end

      private

      def start_timer
        @timer_thread = Thread.new do
          while @running
            sleep(@flush_interval)
            begin
              flush if @running
            rescue StandardError => e
              logger.error("[EventEngine::Cloud] Timer thread error: #{e.class} - #{e.message}")
            end
          end
        end
      end

      def stop_timer
        return unless @timer_thread

        @timer_thread.join([@flush_interval * 2, 5].min)
        @timer_thread.kill if @timer_thread.alive?
        @timer_thread = nil
      end

      def push(entry)
        return unless @running && @batch

        @batch.push(entry)
        flush if @batch.full?
      end

      def logger
        EventEngine.configuration.logger
      end
    end
  end
end
