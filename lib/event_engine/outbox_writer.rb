module EventEngine
  class OutboxWriter
    def self.write(attrs)
      OutboxEvent.create!(attrs)
    end
  end
end
