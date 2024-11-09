# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:plans) do
      primary_key   :id
      foreign_key   :origin_id, :locations, null: false, on_delete: :cascade
      foreign_key   :destination_id, :locations, null: false, on_delete: :cascade
      String        :query_id, null: true

      String        :strategy, null: false
      Integer       :duration, null: true
      Integer       :distance, null: true

      DateTime      :created_at
      DateTime      :updated_at

      index :query_id
    end
  end
end
