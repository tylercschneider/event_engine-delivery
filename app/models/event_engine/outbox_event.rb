module EventEngine
  # Represents an event persisted in the outbox table. Events are written here
  # before being published through a transport, implementing the outbox pattern
  # for reliable delivery.
  #
  # @!attribute [rw] event_name
  #   @return [String] the event name (e.g. "cow_fed")
  # @!attribute [rw] event_type
  #   @return [String] the event type (e.g. "domain")
  # @!attribute [rw] event_version
  #   @return [Integer] the schema version
  # @!attribute [rw] payload
  #   @return [Hash] the event payload data
  # @!attribute [rw] metadata
  #   @return [Hash, nil] optional contextual metadata
  # @!attribute [rw] idempotency_key
  #   @return [String, nil] unique key for deduplication
  # @!attribute [rw] attempts
  #   @return [Integer] number of publish attempts
  # @!attribute [rw] published_at
  #   @return [Time, nil] when the event was successfully published
  # @!attribute [rw] dead_lettered_at
  #   @return [Time, nil] when the event was dead-lettered
  # @!attribute [rw] occurred_at
  #   @return [Time] when the event occurred
  class OutboxEvent < ApplicationRecord
    self.table_name = "event_engine_outbox_events"

    attr_readonly :event_name, :event_type, :event_version, :payload,
                  :metadata, :occurred_at, :idempotency_key

    validates :event_name, presence: true
    validates :event_type, presence: true
    validates :payload, presence: true
    validates :idempotency_key, uniqueness: true, allow_nil: true

    # @!scope class
    # @!method active
    #   Events that have not been dead-lettered.
    #   @return [ActiveRecord::Relation]
    scope :active, -> { where(dead_lettered_at: nil) }

    # @!scope class
    # @!method dead_lettered
    #   Events that have been dead-lettered after exceeding max attempts.
    #   @return [ActiveRecord::Relation]
    scope :dead_lettered, -> { where.not(dead_lettered_at: nil) }

    # @!scope class
    # @!method ordered
    #   Events ordered by creation time (FIFO).
    #   @return [ActiveRecord::Relation]
    scope :ordered, -> { order(:created_at) }

    # @!scope class
    # @!method retryable(max_attempts)
    #   Events with fewer attempts than the maximum.
    #   @param max_attempts [Integer]
    #   @return [ActiveRecord::Relation]
    scope :retryable, ->(max_attempts) { where("attempts < ?", max_attempts) }

    # @!scope class
    # @!method unpublished
    #   Events not yet published.
    #   @return [ActiveRecord::Relation]
    scope :unpublished, -> { where(published_at: nil) }

    # @!scope class
    # @!method published_before(time)
    #   Events published before a given time (for cleanup).
    #   @param time [Time]
    #   @return [ActiveRecord::Relation]
    scope :published_before, ->(time) { where("published_at < ?", time) }

    # @!scope class
    # @!method cleanable
    #   Published events that are not dead-lettered (safe to delete).
    #   @return [ActiveRecord::Relation]
    scope :cleanable, -> { where.not(published_at: nil).where(dead_lettered_at: nil) }

    scope :for_aggregate, ->(type, id) { where(aggregate_type: type, aggregate_id: id).ordered }

    def self.next_aggregate_version(type, id)
      max = where(aggregate_type: type, aggregate_id: id).maximum(:aggregate_version)
      (max || 0) + 1
    end

    # Marks the event as dead-lettered.
    #
    # @return [void]
    def dead_letter!
      update!(dead_lettered_at: Time.current)
    end

    # Whether the event has been dead-lettered.
    #
    # @return [Boolean]
    def dead_lettered?
      dead_lettered_at.present?
    end

    # Resets the event for retry by clearing attempts and dead-letter status.
    #
    # @return [void]
    def retry!
      update!(attempts: 0, dead_lettered_at: nil, last_error_message: nil, last_error_class: nil)
    end

    # Increments the attempt counter.
    #
    # @return [void]
    def increment_attempts!
      update!(attempts: (attempts || 0) + 1)
    end

    # Marks the event as successfully published.
    #
    # @return [void]
    def mark_published!
      update!(published_at: Time.current)
    end
  end
end
