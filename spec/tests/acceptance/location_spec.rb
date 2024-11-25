# frozen_string_literal: true

require_relative '../../spec_helper'
require 'rack/test'

def app
  Leaf::App
end

describe 'Test the location route' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('acceptance_location', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return location information' do
      get '/locations'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'Leaf API v1 at /'
    end
  end
end
