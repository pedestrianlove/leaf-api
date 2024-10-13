# frozen_string_literal: true

require 'http'
require_relative 'api_errors'

module LeafAPI
  module Service
    # This is the service class to make API requests to NTHUSA API:
    # https://api.nthusa.tw/docs
    class NTHUAPI
      def initialize
        @http = HTTP.accept(:json).persistent('https://api.nthusa.tw')
      end

      # Given a bus stop, type, direction and day, obtain the schedule.
      # Refer to: https://api.nthusa.tw/docs#/Buses/get_stop_bus_buses_stops__stop_name___get
      # @param  stop_name   [String]  Possible values: [
      #                                 '北校門口', '綜二館', '楓林小徑', '人社院&生科館',
      #                                 '台積館', '奕園停車場', '南門停車場', '南大校區校門口右側(食品路校牆邊)'
      #                                 ]
      # @param  type        [String]  Possible values: ['all', 'main', 'nanda'].
      # @param  direction   [String]  Possible values: ['up', 'down']
      # @option day         [String]  Possible values: ['all', 'weekday', 'weekend', 'current']
      def bus_schedule(stop_name, type, direction, day)
        response = @http.get("/buses/stops/#{stop_name}/", params: {
                               bus_type: type,
                               direction: direction,
                               day: day
                             })

        raise HTTPError.new(response.status.to_s), 'by NTHUAPI' unless response.status.success?

        response.parse
      end
    end
  end
end
