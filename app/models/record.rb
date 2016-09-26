class Record < ActiveRecord::Base
  enum status: [ :inactive, :active ]

  belongs_to :user, foreign_key: :user_id
  belongs_to :image, foreign_key: :image_id

  validates_uniqueness_of :image_id, :scope => :user_id
end