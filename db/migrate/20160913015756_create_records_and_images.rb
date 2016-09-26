class CreateRecordsAndImages < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.integer  :user_id
      t.integer  :image_id
      t.datetime :created_at
      t.timestamps
    end

    create_table :images do |t|
      t.string   :name
      t.string   :tag
      t.text     :description
      t.datetime :date
    end
  end
end
