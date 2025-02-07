require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "アソシエーションのテスト" do
    it { should have_many(:recipes) }
  end

  describe "バリデーションのテスト" do
    it { should validate_presence_of(:name).with_message("を入力してください") }
  end
end
