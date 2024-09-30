# frozen_string_literal: true

require 'http'

# This is the service class to make API requests to NTHUSA API:
# https://api.nthusa.tw/docs
class NTHUAPI
  def initialize
    @http = HTTP.accept(:json).persistent('https://api.nthusa.tw')
  end

  def bus_schedule(stop_name, _type, _direction, _day)
    @http.get("/buses/stops/#{stop_name}/", params: {
                bus_type: 'type',
                direction: 'up',
                day: 'current'
              }).parse
  end
end
