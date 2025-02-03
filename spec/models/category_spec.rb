require 'rails_helper'

RSpec.describe Category, type: :model do
  describe "アソシエーションのテスト" do
    it { should have_many(:recipes) }
  end
end
