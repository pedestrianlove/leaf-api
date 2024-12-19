# frozen_string_literal: true

require 'time'

module Leaf
  module NTHUSA
    # Class to map the data from google maps api to the Trip entity
    class ScheduleMapper
      def initialize(gateway_class)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
      end

      def find(start_stop, end_stop)
        start_data = @gateway.bus_schedule(start_stop, 'main', 'up',
                                           'current') + @gateway.bus_schedule(start_stop, 'main', 'down', 'current')
        start_detail = @gateway.bus_detailed_schedule('main', 'up',
                                                      'current') + @gateway.bus_detailed_schedule('main', 'down',
                                                                                                  'current')
        result = filter_schedule(start_stop, start_data, start_detail, end_stop)

        DataMapper.new(result, start_stop, end_stop).build_entity
      end

      private

      def time_in_order?(start_time, end_time)
        Time.parse(start_time) <= Time.parse(end_time)
      end

      # Function to find intersection and filter invalid entries
      def filter_schedule(start_stop, start_data, start_detail, end_stop) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        # Filter out relevant detail entries
        result = start_detail.select do |detail|
          # find the entry that matches one of the start_data array's entry attribute: entry['bus_info]
          start_data.any? do |data|
            detail['arrive_time'] = data['arrive_time']
            detail['stop_name'] = start_stop
            qualified_end_stop_info = detail['stops_time'].find do |stop_info|
              stop_info['stop_name'] == end_stop
            end
            detail['final_arrive_time'] = qualified_end_stop_info['time']

            data['bus_info'] == detail['dep_info']
          end
        end

        # Filter out invalid entries
        result.select do |entry|
          time_in_order?(entry['arrive_time'], entry['final_arrive_time'])
        end
      end

      # This class maps the response data from Google Maps API to a Location entity.
      # It extracts necessary information such as name, latitude, and longitude.
      class DataMapper
        def initialize(result, origin, destination)
          @data = result
          @origin = origin
          @destination = destination
        end

        def build_entity
          @data.map do |entry|
            Leaf::Entity::Schedule.new(
              origin: @origin,
              destination: @destination,
              leave_at: Time.parse(entry['arrive_time']),
              arrive_at: Time.parse(entry['final_arrive_time'])
            )
          end
        end
      end
    end
  end
end
