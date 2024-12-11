# frozen_string_literal: true

require_relative '../../spec_helper'
require 'rack/test'

def app
  Leaf::App
end

describe 'Test Trip Routes with Representer' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('acceptance_trip', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'Trip submission' do
    it 'should successfully submit a new trip and return trip ID' do
      post '/trip', origin: 'New York', destination: 'Los Angeles', strategy: 'driving'

      _(last_response.status).must_equal 201
      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'success'
      _(body).must_include 'trip_id'
    end

    it 'should fail to submit a trip with missing fields' do
      post '/trip', origin: 'New York', strategy: 'driving'

      _(last_response.status).must_equal 400
      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'error'
      _(body['message']).must_include 'Invalidated trip input'
    end
  end

  describe 'Trip result' do
    it 'should retrieve trip results for a valid trip ID' do
      post '/trip', origin: 'New York', destination: 'Los Angeles', strategy: 'driving'
      trip_id = JSON.parse(last_response.body)['trip_id']

      get "/trip/#{trip_id}"

      _(last_response.status).must_equal 200
      body = JSON.parse(last_response.body)
      _(body).must_include 'id'
      _(body).must_include 'origin'
      _(body).must_include 'destination'
      _(body).must_include 'strategy'
      _(body).must_include 'distance'
      _(body).must_include 'duration'
    end

    it 'should fail to retrieve trip results for an invalid trip ID' do
      get '/trip/invalid_trip_id'

      _(last_response.status).must_equal 404
      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'error'
      _(body['message']).must_include 'Trip not found'
    end
  end

  describe 'General errors' do
    it 'should return 404 for an undefined route' do
      get '/undefined_route'

      _(last_response.status).must_equal 404
      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'error'
      _(body['message']).must_include 'Route not found'
    end
  end
end
