class Image < ActiveRecord::Base
  has_many :records
  has_many :users, :through => :records

  validates :description, presence: true
end