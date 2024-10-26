# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:locations) do
      drop_column :longtitude
      add_column :longitude, Float
    end
  end
end
