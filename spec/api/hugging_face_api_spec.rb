# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative '../../lib/services/llama_api'
require_relative '../../lib/services/api_errors'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')
BAD_SECRETS = YAML.safe_load_file('config/secrets.yaml.example')
CORRECT_RESPONSE = YAML.safe_load_file('spec/fixtures/Llama_response-results.yaml')

describe 'Test Huggingface API API library' do
  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token.' do
      _(proc do
        LlamaAPI.new(BAD_SECRETS['HUGGINGFACE_API_KEY'])
                     .generate_text('Tell me a joke')
      end).must_raise HTTPError
    end
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      payload = LlamaAPI.new(CORRECT_SECRETS['HUGGINGFACE_API_KEY'])
                        .generate_text('Tell me a joke')
      _(payload[0]['generated_text']).wont_be_nil
    end
  end
end
