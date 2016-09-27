class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :records
  has_many :images, :through => :records

  validates :name, presence: true

  def images
    Record.where("user_id = ?", self.id).includes(:image).map { |e| [e.status, e.image] }
  end
end
