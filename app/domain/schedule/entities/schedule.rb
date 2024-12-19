# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'time'

module Leaf
  module Entity
    # This is a class to represent the concept of trip on the map.
    # This may include strategies like 'driving', 'bicycling', 'school_bus', 'walking', 'trasit'...etc.
    class Schedule < Dry::Struct
      include Dry.Types

      attribute :origin, String.enum('北校門口', '綜二館', '楓林小徑', '人社院&生科館', '台積館', '奕園停車場', '南門停車場')
      attribute :destination, String.enum('北校門口', '綜二館', '楓林小徑', '人社院&生科館', '台積館', '奕園停車場', '南門停車場')
      attribute :leave_at, Time
      attribute :arrive_at, Time

      def to_attr_hash
        to_hash
      end
    end
  end
end
