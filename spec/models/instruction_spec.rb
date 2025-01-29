require 'rails_helper'

RSpec.describe Instruction, type: :model do
  let(:recipe) { create(:recipe) }
  let!(:instruction) { create(:instruction) }

  describe "バリデーションのテスト" do
    it { should validate_presence_of(:description).with_message("を入力してください") }
    it { should validate_length_of(:description).is_at_most(100).with_message("は100文字以内で入力してください") }
  end

  describe "アソシエーションのテスト" do
    it { should belong_to(:recipe) }
  end

  describe "コールバックのテスト" do
    context "before_create: assign_steps" do
      it "assign_stepsでstepが適切に設定されること" do
        expect(instruction.step).to eq(4)
      end
    end

    context "before_destroy: reorder_steps" do
      it 'instruction削除後にstepが再順序付けされること' do
        new_instruction = create(:instruction, recipe: recipe)
        instruction.destroy
        recipe.reload

        expect(new_instruction.step).to eq(4)
        expect(recipe.instructions.pluck(:step)).to eq([1, 2, 3, 4])
      end
    end
  end
end
