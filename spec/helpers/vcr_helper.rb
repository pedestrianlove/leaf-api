# frozen_string_literal: true

require 'vcr'
require 'webmock'

module VCRHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
    end
  end

  def self.configure_vcr_for(gateway_name, token_name = nil, token = nil)
    if token_name
      VCR.configure do |c|
        c.filter_sensitive_data("<#{token_name}>") { token }
        c.filter_sensitive_data("<#{token_name}_ESC>") { CGI.escape(token) }
      end
    end

    VCR.insert_cassette(
      gateway_name,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
