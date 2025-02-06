class Recipe < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :ingredients, dependent: :destroy
  has_many :instructions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  accepts_nested_attributes_for :ingredients, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :instructions, allow_destroy: true, reject_if: :all_blank

  mount_uploader :recipe_image, RecipeImageUploader

  scope :recent, -> { includes(:user).order(created_at: :desc) }

  validates :title, presence: true, length: { maximum: 30 }
  validates :work_name, presence: true, length: { maximum: 30 }
  validates :recipe_image, presence: true
  validates :tip, presence: true, length: { maximum: 200 }
  validates :ingredients, presence: { message: "を少なくとも1つ追加してください。" }
  validates :instructions, presence: { message: "を少なくとも1つ追加してください。" }
end
