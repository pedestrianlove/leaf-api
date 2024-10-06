# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'

# This is the service class to make API requests to Huggingface endpoint:
# https://huggingface.co/docs/api-inference/index
class LlamaAPI
  def initialize
    # Initialize the HTTP client and load API key from the secrets YAML file
    @http = HTTP.accept(:json).follow.persistent('https://api-inference.huggingface.co')
    @secret = YAML.safe_load_file('config/secrets.yaml')['HUGGINGFACE_API_KEY'] # Load API key from secrets file
  end

  # Generate a text completion based on a given prompt.
  # @param prompt [String] The text prompt for the completion.
  # @param model  [String] The model to use (default: 'meta-llama/Llama-3.2-1B').
  def generate_text(prompt, model = 'meta-llama/Llama-3.2-1B')
    response = @http.post("/models/#{model}",
                          headers: { 'Authorization' => "Bearer #{@secret}" },
                          json: { inputs: prompt })
    output = JSON.parse(response.body)
    output[0]['generated_text']
  end
end
