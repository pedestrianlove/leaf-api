# frozen_string_literal: true

require_relative '../../spec_helper'
require 'rack/test'
require_relative '../../../app/infrastructure/database/orm/location_orm'

def app
  Leaf::App
end

describe 'Test Location API' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr
  before(:each) do
    VCRHelper.configure_vcr_for('acceptance_location', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database

    # 初始化測試數據
    @session = { visited_locations: ['Taipei'] }
    Leaf::Database::LocationOrm.find_or_create(
      name: 'Taipei',
      latitude: 25.033,
      longitude: 121.565,
      plus_code: '7QP2QVXF+PR'
    )
    # puts Leaf::Database::LocationOrm.first(name: 'Taipei').inspect
  end

  after(:each) do
    DatabaseHelper.wipe_database
    VCRHelper.eject_vcr
  end

  it 'should create a new location' do
    post '/locations', { location: 'Taipei' }.to_json, 'CONTENT_TYPE' => 'application/json'
    # puts 'POST request path: /locations'
    # puts "POST request params: #{last_request.env['rack.input'].read}" # 查看原始請求體
    # puts "Response status: #{last_response.status}" # 查看狀態碼
    # puts "Response body: #{last_response.body}"     # 查看返回內容
    _(last_response.status).must_equal 201

    location = JSON.parse(last_response.body)
    _(location['name']).must_equal 'Taipei, Taiwan' # 傳回來會變Taipei, Taiwan
  end

  it 'should delete a location' do
    delete '/locations/Taipei', {}, 'rack.session' => { visited_locations: ['Taipei'] }
    # puts 'DELETE request path: /locations/Taipei'
    # puts "DELETE request session: #{last_request.env['rack.session']}"
    # puts "Response status: #{last_response.status}" # 調試輸出
    # puts "Response body: #{last_response.body}" # 調試輸出
    _(last_response.status).must_equal 204

    # 確認 session 狀態是否已清空
    _(last_request.env['rack.session'][:visited_locations]).must_be_nil

    # 確認資料庫中不再存在該位置
    db_location = Leaf::Database::LocationOrm.first(name: 'Taipei')
    _(db_location).must_be_nil
  end

  # it 'should not allow creating duplicate locations' do
  #   2.times do
  #     post '/locations', { location: 'Taipei' }.to_json, 'CONTENT_TYPE' => 'application/json'
  #   end

  #   _(last_response.status).must_equal 201
  #   db_count = Leaf::Database::LocationOrm.where(name: 'Taipei').count
  #   _(db_count).must_equal 1
  # end

  it 'should return 404 when deleting non-existent location' do
    delete '/locations/NonExistent', {}, 'rack.session' => { visited_locations: [] }
    _(last_response.status).must_equal 404
    _(JSON.parse(last_response.body)['message']).must_include 'not found'
  end
end
