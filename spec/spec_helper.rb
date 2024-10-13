# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit' # minitest Github issue #17 requires
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/leaf_api'

CORRECT_SECRETS = YAML.safe_load_file('config/secrets.yaml')
BAD_SECRETS = YAML.safe_load_file('config/secrets.yaml.example')

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
