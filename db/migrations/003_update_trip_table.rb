# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    alter_table(:trips) do
      add_column :query_id, String

      add_index :query_id
    end
  end
end
