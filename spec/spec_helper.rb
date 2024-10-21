# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit' # minitest Github issue #17 requires
require 'minitest/rg'

require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

require_relative '../require_app'
require_app

CORRECT_SECRETS = LeafAPI::App.config
BAD_SECRETS = YAML.safe_load_file('config/secrets.yaml')['test']
