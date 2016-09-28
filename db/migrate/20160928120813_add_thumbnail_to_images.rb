class AddThumbnailToImages < ActiveRecord::Migration
  def change
    add_column :images, :thumbnail, :string, :default => "http://www.thatpetplace.com/c.1043140/site/img/photo_na.jpg"
  end
end
