# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    # FIXME
    LeafAPI::App.db.run('PRAGMA foreign_keys = OFF')
    # LeafAPI::Database::LocationOrm.map(&:destroy)
    # LeafAPI::Database::TripOrm.map(&:destroy)
    LeafAPI::App.db.run('PRAGMA foreign_keys = ON')
  end
end
