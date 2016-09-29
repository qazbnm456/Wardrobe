class AddThumbnailToImages < ActiveRecord::Migration
  def change
    add_column :images, :thumbnail, :string, :default => "https://i.imgur.com/do1g7qu.jpg"
  end
end
