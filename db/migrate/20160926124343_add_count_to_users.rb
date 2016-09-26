class AddCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :count, :integer, default: 0
  end
end
