class AddStackIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stackId, :string, default: ''
  end
end
