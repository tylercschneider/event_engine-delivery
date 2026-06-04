module EventEngine
  module Dashboard
    class HomeController < BaseController
      def index
        @total = OutboxEvent.count
        @published = OutboxEvent.where.not(published_at: nil).count
        @unpublished = OutboxEvent.unpublished.active.count
        @dead_lettered = OutboxEvent.dead_lettered.count
      end
    end
  end
end
