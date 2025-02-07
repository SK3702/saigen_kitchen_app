require 'rails_helper'

RSpec.describe Favorite, type: :model do
  let!(:favorite) { create(:favorite) }

  describe "バリデーションのテスト" do
    it { should validate_uniqueness_of(:user_id).scoped_to(:recipe_id) }
  end

  describe "アソシエーションのテスト" do
    it { should belong_to(:user) }
    it { should belong_to(:recipe) }
  end
end
