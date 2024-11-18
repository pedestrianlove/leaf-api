# frozen_string_literal: true

require 'figaro'
require 'logger'
require 'rack/session'
require 'roda'
require 'sequel'

module Leaf
  # Initialize the App class with the environmental information.
  class App < Roda
    plugin :environments

    configure do
      # Environment variables setup
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yaml')
      )
      Figaro.load
      def self.config = Figaro.env

      use Rack::Session::Cookie, secret: config.SESSION_SECRET

      configure :development, :test do
        Figaro.require_keys('DB_FILENAME')
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      # Database Setup
      @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
      def self.db = @db # rubocop:disable Style/TrivialAccessors

      # Logger Setup
      @logger = Logger.new($stderr)
      class << self
        attr_reader :logger
      end
    end
  end
end
