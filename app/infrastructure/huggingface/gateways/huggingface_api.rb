# frozen_string_literal: true

require 'http'
require 'json'

require_relative '../../utils'

module LeafAPI
  module HuggingFace
    # This is the service class to make API requests to Huggingface endpoint:
    # https://huggingface.co/docs/api-inference/index
    class API
      def initialize(secret)
        # Initialize the HTTP client and load API key from the secrets YAML file
        @http = HTTP.accept(:json).follow.persistent('https://api-inference.huggingface.co')
        @secret = secret
      end

      # Generate a text completion based on a given prompt.
      # @param prompt [String] The text prompt for the completion.
      # @param model  [String] The model to use (default: 'meta-llama/Llama-3.2-1B').
      def generate_text(prompt, model = 'meta-llama/Llama-3.2-1B')
        response = @http.post("/models/#{model}",
                              headers: { 'Authorization' => "Bearer #{@secret}" },
                              json: { inputs: prompt })

        Response.new(response).handle_error('by HuggingFaceAPI')
      end
    end
  end
end
