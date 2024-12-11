# frozen_string_literal: true

require_relative '../../../spec_helper'
require 'rack/test'

def app
  Leaf::App
end

describe 'Test Query Get API' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('acceptance_query_get', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database

    # 初始化資料庫
    post '/queries', {
      origin: 'National Tsing Hua University, Taiwan',
      destination: 'National Yang Ming Chiao Tung University, Taiwan',
      strategy: 'walking'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    @query_id = JSON.parse(last_response.body)['id']
  end

  after do
    DatabaseHelper.wipe_database
    VCRHelper.eject_vcr
  end

  it 'should get a query object with a good query_id' do
    get "/queries/#{@query_id}", 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 200

    # Check Database
    body = JSON.parse(last_response.body)
    query_representer = Leaf::Representer::Query.new(body)
    _(query_representer).must_be_instance_of Leaf::Representer::Query
  end

  it 'should get a query object with a good query_id' do
    get '/queries/i-am-a-bad-query-id', 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 400

    # Check Database
    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'bad_request'
    _(body['message']).must_include 'Fetching query'
  end
end
