# frozen_string_literal: true

require 'roda'
require 'yaml'

module LeafAPI
  class App < Roda
    CONFIG = YAML.safe_load_file('config/secrets.yaml')
  end
end
