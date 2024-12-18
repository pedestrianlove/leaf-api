# frozen_string_literal: true

require_relative '../../../spec_helper'
require 'rack/test'
require 'time'

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
    result = Leaf::Service::AddQuery.new.call({
                                                'id' => SecureRandom.uuid,
                                                'origin' => 'National Tsing Hua University, Taiwan',
                                                'destination' => 'National Yang Ming Chiao Tung University, Taiwan',
                                                'strategy' => 'walking'
                                              })

    @query = result.value!.message
    @query.plans.each do |plan|
      _(plan.arrive_at).must_be_instance_of Time
      _(plan.arrive_at).wont_be_nil
      _(plan.leave_at).must_be_instance_of Time
      _(plan.leave_at).wont_be_nil
    end
    @query_id = @query.id
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
    query_representer = Leaf::Representer::Query.new(OpenStruct.new).from_hash(body)
    _(query_representer).must_be_instance_of OpenStruct
    query_representer.plans.each do |plan|
      _(plan.arrive_at).must_be_instance_of String
      _(Time.parse(plan.arrive_at)).must_be_instance_of Time
      _(plan.arrive_at).wont_be_nil
      _(plan.leave_at).must_be_instance_of String
      _(Time.parse(plan.leave_at)).must_be_instance_of Time
      _(plan.leave_at).wont_be_nil
    end
  end

  it 'should get an error with a wrong query_id' do
    get "/queries/#{SecureRandom.uuid}", 'CONTENT_TYPE' => 'application/json'
    _(last_response.status).must_equal 404

    # Check Database
    body = JSON.parse(last_response.body)
    _(body['status']).must_include 'not_found'
    _(body['message']).must_include 'Fetching query'
  end
end
