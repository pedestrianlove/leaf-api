# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:trips) do
      primary_key   :id
      foreign_key   :origin_id, :locations, null: false, on_delete: :cascade
      foreign_key   :destination_id, :locations, null: false, on_delete: :cascade

      String        :strategy, null: false
      Integer       :duration, null: false
      Integer       :distance, null: false

      DateTime      :created_at
      DateTime      :updated_at
    end
  end
end
