# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Huggingface API API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<HUGGINGFACE_API_KEY>') { CORRECT_SECRETS['HUGGINGFACE_API_KEY'] }
    c.filter_sensitive_data('<HUGGINGFACE_API_KEY_ESC>') { CGI.escape(CORRECT_SECRETS['HUGGINGFACE_API_KEY']) }
  end

  before do
    VCR.insert_cassette 'huggingface_api',
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token.' do
      _(proc do
        LeafAPI::Service::LlamaAPI.new(BAD_SECRETS['HUGGINGFACE_API_KEY'])
                     .generate_text('Tell me a joke')
      end).must_raise LeafAPI::Service::HTTPError
    end
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      YAML.safe_load_file('spec/fixtures/Llama_response-results.yaml')
      payload = LeafAPI::Service::LlamaAPI.new(CORRECT_SECRETS['HUGGINGFACE_API_KEY'])
                                          .generate_text('Tell me a joke')
      _(payload[0]['generated_text']).wont_be_nil
    end
  end
end
