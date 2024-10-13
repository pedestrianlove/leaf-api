# frozen_string_literal: true

module LeafAPI
  module Service
    # Class for representing HTTP related errors
    class HTTPError < StandardError
      attr_reader :message

      def initialize(message)
        super
        @message = message
      end
    end
  end
end
