# frozen_string_literal: true

require_relative '../../../spec_helper'
require 'rack/test'

def app
  Leaf::App
end

describe 'Test Query Create API' do
  include Rack::Test::Methods

  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('acceptance_query_create', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    DatabaseHelper.wipe_database
  end

  after do
    DatabaseHelper.wipe_database
    VCRHelper.eject_vcr
  end

  it 'should create a new query on request with normal json' do
    post '/queries', {
      origin: 'National Tsing Hua University, Taiwan',
      destination: 'National Yang Ming Chiao Tung University, Taiwan',
      strategy: 'walking'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 201

    body = JSON.parse(last_response.body)
    _(body['id']).must_be_instance_of String

    # Check Database
    query = Leaf::Repository::Query.find_by_id(body['id'])
    _(query).wont_be_nil
  end

  it 'should return error on request with bad json' do
    post '/queries', 'helloworld!', 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 400

    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'bad_request'
    _(body['message']).must_include 'Bad JSON format.'
  end

  it 'should return error on request missing fields: origin' do
    post '/queries', {
      destination: 'National Yang Ming Chiao Tung University, Taiwan',
      strategy: 'walking'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 500

    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'internal_error'
    _(body['message']).must_include 'Parse query location: is missing'
  end

  it 'should return error on request missing fields: destination' do
    post '/queries', {
      origin: 'National Tsing Hua University, Taiwan',
      strategy: 'walking'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 500

    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'internal_error'
    _(body['message']).must_include 'Parse query location: is missing'
  end

  it 'should return error on request missing fields: strategy' do
    post '/queries', {
      origin: 'National Tsing Hua University, Taiwan',
      destination: 'National Yang Ming Chiao Tung University, Taiwan'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 500

    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'internal_error'
    _(body['message']).must_include 'Parse query location: is missing'
  end

  it 'should return error on request with bad strategy type' do
    post '/queries', {
      origin: 'National Tsing Hua University, Taiwan',
      destination: 'National Yang Ming Chiao Tung University, Taiwan',
      strategy: 'dancing'
    }.to_json, 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 500

    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'internal_error'
    _(body['message']).must_include 'is an invalid strategy'
  end
end
