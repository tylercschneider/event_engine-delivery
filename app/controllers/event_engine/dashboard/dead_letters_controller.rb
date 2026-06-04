module EventEngine
  module Dashboard
    class DeadLettersController < BaseController
      PER_PAGE = 20

      def index
        @page = (params[:page] || 1).to_i
        @events = OutboxEvent.dead_lettered
                             .order(dead_lettered_at: :desc)
                             .offset((@page - 1) * PER_PAGE)
                             .limit(PER_PAGE)
        @total = OutboxEvent.dead_lettered.count
        @total_pages = [(@total.to_f / PER_PAGE).ceil, 1].max
      end

      def retry
        event = OutboxEvent.dead_lettered.find(params[:id])
        event.retry!
        redirect_to dashboard_dead_letters_path, notice: "Event #{event.id} queued for retry"
      end

      def retry_all
        OutboxEvent.dead_lettered.find_each(&:retry!)
        redirect_to dashboard_dead_letters_path, notice: "All dead-lettered events queued for retry"
      end
    end
  end
end
