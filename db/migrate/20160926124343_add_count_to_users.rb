class AddCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :count, :integer, default: 1 # Default is One instance available
  end
end
