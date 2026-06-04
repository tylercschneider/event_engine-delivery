module EventEngine
  module Dashboard
    class BaseController < ApplicationController
      before_action :authenticate_dashboard!

      private

      def authenticate_dashboard!
        auth = EventEngine.configuration.dashboard_auth

        unless auth
          EventEngine.configuration.logger.warn(
            "[EventEngine] Dashboard access denied: dashboard_auth is not configured. " \
            "Set config.dashboard_auth in your EventEngine initializer to a callable that " \
            "returns true for authorized users."
          )
        end

        unless auth && auth.call(self)
          render plain: "Forbidden", status: :forbidden
        end
      end
    end
  end
end
