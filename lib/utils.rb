# frozen_string_literal: true

module LeafAPI
  # Class for representing HTTP related errors
  class HTTPError < StandardError
    attr_reader :message

    def initialize(message)
      super
      @message = message
    end
  end

  # Class for handling requests / error
  class Response < SimpleDelegator
    def handle_error(message, extra = nil)
      raise HTTPError.new(status.to_s), message unless status.success?

      raise HTTPError.new(extra), message if extra

      parse
    end
  end
end
