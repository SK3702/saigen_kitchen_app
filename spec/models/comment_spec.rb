require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe "バリデーションのテスト" do
    it { should validate_presence_of(:content).with_message("を入力してください") }
    it { should validate_length_of(:content).is_at_most(200).with_message("は200文字以内で入力してください") }
  end

  describe "アソシエーションのテスト" do
    it { should belong_to(:user) }
    it { should belong_to(:recipe) }
  end
end
