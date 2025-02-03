class Instruction < ApplicationRecord
  belongs_to :recipe
  before_create :assign_steps
  before_destroy :reorder_steps

  validates :description, presence: true
  validates :description, length: { maximum: 100 }

  private

  def assign_steps
    self.step = recipe.instructions.maximum(:step).to_i + 1
  end

  def reorder_steps
    recipe.instructions.where.not(id: id).order(:id).each_with_index do |instruction, index|
      instruction.update_column(:step, index + 1)
    end
  end
end
