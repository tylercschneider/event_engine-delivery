EventEngine.configure do |c|
  # Delivery strategy (:inline or :active_job)
  # c.delivery_adapter = :active_job

  # Publisher behavior
  # c.batch_size = 100
  # c.max_attempts = 5

  # Transport (required for publishing)
  #
  # kafka = Kafka.new(seed_brokers: ENV["KAFKA_BROKERS"])
  # producer = EventEngine::KafkaProducer.new(client: kafka)
  # c.transport = EventEngine::Transports::Kafka.new(producer: producer)
end
