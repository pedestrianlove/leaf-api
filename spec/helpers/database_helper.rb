# frozen_string_literal: true

# Helper to clean database during test runs
module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    db = Leaf::App.db
    db.run('PRAGMA foreign_keys = OFF')
    Leaf::Database::LocationOrm.map(&:destroy)
    Leaf::Database::TripOrm.map(&:destroy)
    db.run('PRAGMA foreign_keys = ON')
  end
end
