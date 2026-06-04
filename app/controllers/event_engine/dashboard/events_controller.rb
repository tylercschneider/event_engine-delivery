module EventEngine
  module Dashboard
    class EventsController < BaseController
      PER_PAGE = 20

      def index
        @page = (params[:page] || 1).to_i
        @events = OutboxEvent.order(created_at: :desc)
                             .offset((@page - 1) * PER_PAGE)
                             .limit(PER_PAGE)
        @total = OutboxEvent.count
        @total_pages = (@total.to_f / PER_PAGE).ceil
      end

      def show
        @event = OutboxEvent.find(params[:id])
      end
    end
  end
end
