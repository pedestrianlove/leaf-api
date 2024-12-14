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

    # 使用 Google Maps API 查詢地點並插入正確的數據
    VCR.use_cassette('google_maps_taipei') do
      mapper = Leaf::GoogleMaps::LocationMapper.new(
        Leaf::GoogleMaps::API,
        CORRECT_SECRETS.GOOGLE_TOKEN
      )
      location_data = mapper.find('Taipei, Taiwan')
      Leaf::Database::LocationOrm.find_or_create(
        name: location_data.name,
        latitude: location_data.latitude,
        longitude: location_data.longitude,
        plus_code: location_data.plus_code
      )
    end
  end

  after do
    DatabaseHelper.wipe_database
    VCRHelper.eject_vcr
  end

  it 'should create a new location and return Plus Code' do
    VCR.use_cassette('google_maps_new_york') do
      post '/locations', { location: 'New York' }.to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 201

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'created'
      _(body['plus_code']).wont_be_nil

      # 確認數據庫中是否新增了正確的地點
      db_location = Leaf::Database::LocationOrm.first(plus_code: body['plus_code'])
      _(db_location).wont_be_nil
      _(db_location.name).must_include 'New York'
    end
  end

  it 'should retrieve a location by Plus Code' do
    encoded_plus_code = CGI.escape('7QQ32H00+')
    get "/locations/#{encoded_plus_code}"
    _(last_response.status).must_equal 200

    body = JSON.parse(last_response.body)
    _(body['plus_code']).must_equal '7QQ32H00+'
    _(body['name']).must_equal 'Taipei, Taiwan'
  end

  it 'should allow re-posting the same location and return its information' do
    VCR.use_cassette('google_maps_taipei') do
      post '/locations', { location: 'Taipei, Taiwan' }.to_json, 'CONTENT_TYPE' => 'application/json'
      _(last_response.status).must_equal 200 # 確認返回已存在的地點

      body = JSON.parse(last_response.body)
      _(body['plus_code']).must_equal '7QQ32H00+'
      _(body['name']).must_equal 'Taipei, Taiwan'

      # 確認數據庫中沒有新增重複地點
      db_locations = Leaf::Database::LocationOrm.where(name: 'Taipei, Taiwan').all
      _(db_locations.size).must_equal 1
    end
  end

  it 'should delete a location by Plus Code' do
    encoded_plus_code = CGI.escape('7QQ32H00+')
    delete "/locations/#{encoded_plus_code}"
    _(last_response.status).must_equal 204

    db_location = Leaf::Database::LocationOrm.first(plus_code: '7QQ32H00+')
    _(db_location).must_be_nil
  end

  it 'should return 404 when trying to retrieve a non-existent location' do
    encoded_plus_code = CGI.escape('NONEXISTENTCODE')
    get "/locations/#{encoded_plus_code}"
    _(last_response.status).must_equal 404

    body = JSON.parse(last_response.body)
    _(body['status']).must_equal 'not_found'
    _(body['message']).must_include 'NONEXISTENTCODE'
  end
end
