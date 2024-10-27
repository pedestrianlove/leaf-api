# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Huggingface API API library' do
  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('huggingface_api', 'HUGGINGFACE_API_KEY', CORRECT_SECRETS.HUGGINGFACE_API_KEY)
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'API Authentication Failed' do
    it 'Raise errors when provided with incorrect token.' do
      _(proc do
        LeafAPI::HuggingFace::API.new(BAD_SECRETS['HUGGINGFACE_API_KEY'])
                     .generate_text('Tell me a joke')
      end).must_raise LeafAPI::HTTPError
    end
  end

  describe 'API Authentication Suceed' do
    it 'Receive correct data.' do
      YAML.safe_load_file('spec/fixtures/Llama_response-results.yaml')
      payload = LeafAPI::HuggingFace::API.new(CORRECT_SECRETS.HUGGINGFACE_API_KEY)
                                         .generate_text('Tell me a joke')
      _(payload[0]['generated_text']).wont_be_nil
    end
  end
end
