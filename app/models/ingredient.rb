class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true
  validates :name, length: { maximum: 20 }
  validates :quantity, presence: true
  validates :quantity, length: { maximum: 20 }
end
