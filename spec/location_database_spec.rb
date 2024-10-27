# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Location ORM and Database' do
  before do
    DatabaseHelper.wipe_database
  end

  describe 'Retrieve and store location' do
    it 'HAPPY: should be able to save location to database' do
      location_info = {
        name: '清華大學',
        latitude: 24.795707,
        longitude: 120.996393
      }

      rebuilt = LeafAPI::Database::LocationOrm.find_or_create(location_info)

      _(rebuilt.name).must_equal(location_info[:name])
      _(rebuilt.latitude).must_equal(location_info[:latitude])
      _(rebuilt.longitude).must_equal(location_info[:longitude])

      db_record = LeafAPI::Database::LocationOrm.first(name: location_info[:name])
      _(db_record).wont_be_nil
      _(db_record.latitude).must_equal(location_info[:latitude])
      _(db_record.longitude).must_equal(location_info[:longitude])
    end

    it 'SAD: should not allow duplicate locations' do
      location_info = {
        name: '清華大學',
        latitude: 24.795707,
        longitude: 120.996393
      }

      LeafAPI::Database::LocationOrm.find_or_create(location_info)

      rebuilt_duplicate = LeafAPI::Database::LocationOrm.find_or_create(location_info)

      db_records_count = LeafAPI::Database::LocationOrm.count
      _(db_records_count).must_equal 1
      _(rebuilt_duplicate.id).must_equal LeafAPI::Database::LocationOrm.first(name: location_info[:name]).id
    end
  end
end
