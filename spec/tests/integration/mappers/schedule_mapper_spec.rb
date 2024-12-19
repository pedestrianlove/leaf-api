# frozen_string_literal: true

require_relative '../../../spec_helper'

describe 'Test ScheduleMapper' do
  VCRHelper.setup_vcr

  before do
    VCRHelper.configure_vcr_for('entity_schedule', 'GOOGLE_TOKEN', CORRECT_SECRETS.GOOGLE_TOKEN)
    @schedule_mapper = Leaf::NTHUSA::ScheduleMapper.new(
      Leaf::NTHUSA::API
    )
  end

  after do
    VCRHelper.eject_vcr
  end

  describe 'Test duration method' do
    Leaf::Entity::Location::STOP_LIST.each do |stop|
      it "Return schedule information for stop #{stop.name}" do
        result = @schedule_mapper.find(
          stop.name, '台積館'
        )

        _(result).must_be_instance_of Array
        _(result).wont_be_empty
        result.each do |schedule|
          _(schedule).must_be_instance_of Leaf::Entity::Schedule
          _(schedule.origin).must_equal stop.name
          _(schedule.destination).must_equal '台積館'
          _(schedule.leave_at).must_be_instance_of Time
          _(schedule.arrive_at).must_be_instance_of Time
        end
      end
    end
  end
end
