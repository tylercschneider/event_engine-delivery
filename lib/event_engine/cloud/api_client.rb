require "net/http"
require "json"
require "uri"

module EventEngine
  module Cloud
    # HTTP client for the EventEngine Cloud ingestion API.
    # Uses +Net::HTTP+ (stdlib) with a 5-second timeout. All errors are
    # rescued and logged — network failures never propagate to the host app.
    class ApiClient
      # @return [Integer] HTTP timeout in seconds
      TIMEOUT = 5

      # @param api_key [String] the Cloud API key
      # @param endpoint [String] the Cloud API base URL
      def initialize(api_key:, endpoint:)
        @api_key = api_key
        @endpoint = endpoint
      end

      # Posts a batch of event entries to the Cloud API.
      #
      # @param entries [Array<Hash>] serialized event metadata entries
      # @return [Boolean] true on success, false on failure
      def send_batch(entries)
        post("/events", { entries: entries })
      end

      # Posts a heartbeat with app and schema info to the Cloud API.
      #
      # @param heartbeat [Hash] heartbeat data
      # @return [Boolean] true on success, false on failure
      def send_heartbeat(heartbeat)
        post("/heartbeat", heartbeat)
      end

      private

      def post(path, body)
        uri = URI("#{@endpoint}#{path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = TIMEOUT
        http.read_timeout = TIMEOUT

        request = Net::HTTP::Post.new(uri.path)
        request["Authorization"] = "Bearer #{@api_key}"
        request["Content-Type"] = "application/json"
        request["X-EventEngine-Gem-Version"] = EventEngine::VERSION
        request.body = JSON.generate(body)

        response = http.request(request)
        response.code.start_with?("2")
      rescue StandardError => e
        EventEngine.configuration.logger.error(
          "[EventEngine::Cloud] API request failed: #{e.class} - #{e.message}"
        )
        false
      end
    end
  end
end
