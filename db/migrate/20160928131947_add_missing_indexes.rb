class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :records, [:image_id, :user_id]
    add_index :records, :user_id
    add_index :records, :image_id
  end
end
