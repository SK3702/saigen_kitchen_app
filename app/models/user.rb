class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  mount_uploader :avatar, AvatarUploader
  validates :name, presence: true
  validates :bio, length: { maximum: 200 }

  has_many :recipes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_recipes, through: :favorites, source: :recipe

  def favorite?(recipe)
    favorite_recipes.include?(recipe)
  end

  def self.guest
    find_or_create_by!(email: 'guest@guest.mail') do |user|
      user.name = 'ゲストユーザー'
      user.password = SecureRandom.urlsafe_base64
    end
  end
end
