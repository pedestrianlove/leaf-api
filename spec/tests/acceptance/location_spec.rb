# frozen_string_literal: true

require_relative '../../spec_helper'
require 'rack/test'

def app
  Leaf::App
end

describe 'Test Location API' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('acceptance_location', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database

    # 初始化測試數據
    Leaf::Database::LocationOrm.find_or_create(
      name: 'Taipei, Taiwan',
      latitude: 25.033,
      longitude: 121.565,
      plus_code: '7QP2QVXF+PR'
    )
  end

  after do
    DatabaseHelper.wipe_database
    VCRHelper.eject_vcr
  end

  it 'should list all locations' do
    get '/locations'
    _(last_response.status).must_equal 200

    body = JSON.parse(last_response.body)
    _(body['locations']).must_include 'Taipei, Taiwan'
  end

  it 'should create a new location using Google Maps API' do
    VCR.use_cassette('google_maps_new_york') do
      post '/locations', { location: 'New York' }.to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 201

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'created'
      _(body['message']).must_include 'New York'

      # 確認資料庫是否已新增
      db_location = Leaf::Database::LocationOrm.first(name: 'New York, NY, USA')
      # 這個傳回來更特別，不是New York, USA是New York, NY, USA
      _(db_location).wont_be_nil
      _(db_location.plus_code).wont_be_nil
      _(db_location.latitude).wont_be_nil
      _(db_location.longitude).wont_be_nil
    end
  end

  it 'should return 400 for missing location name' do
    post '/locations', {}.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 400

    body = JSON.parse(last_response.body)
    _(body['status']).must_equal 'bad_request'
    _(body['message']).must_include 'Missing location name'
  end

  it 'should return 404 when location is not found' do
    VCR.use_cassette('google_maps_non_existent') do
      post '/locations', { location: 'NonExistentPlace' }.to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 404

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'not_found'
      _(body['message']).must_include 'NonExistentPlace'
    end
  end

  it 'should return 409 for duplicate location' do
    post '/locations', { location: 'Taipei, Taiwan' }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 409

    body = JSON.parse(last_response.body)
    _(body['status']).must_equal 'conflict'
    _(body['message']).must_include 'Taipei, Taiwan already exists'
  end

  it 'should delete an existing location' do
    encoded_name = CGI.escape('Taipei, Taiwan')
    delete "/locations/#{encoded_name}"
    _(last_response.status).must_equal 204

    db_location = Leaf::Database::LocationOrm.first(name: 'Taipei, Taiwan')
    _(db_location).must_be_nil
  end

  it 'should return 404 when deleting a non-existent location' do
    encoded_name = CGI.escape('NonExistent')
    delete "/locations/#{encoded_name}"
    _(last_response.status).must_equal 404

    body = JSON.parse(last_response.body)
    _(body['status']).must_equal 'not_found'
    _(body['message']).must_include 'not found'
  end
end
