require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe "バリデーションのテスト" do
    it { should validate_presence_of(:name).with_message("を入力してください") }
    it { should validate_length_of(:name).is_at_most(20).with_message("は20文字以内で入力してください") }
    it { should validate_presence_of(:quantity).with_message("を入力してください") }
    it { should validate_length_of(:quantity).is_at_most(20).with_message("は20文字以内で入力してください") }
  end

  describe "アソシエーションのテスト" do
    it { should belong_to(:recipe) }
  end
end
