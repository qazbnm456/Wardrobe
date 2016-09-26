class AddStatusToRecords < ActiveRecord::Migration
  def change
    add_column :records, :status, :integer, default: 0
  end
end
