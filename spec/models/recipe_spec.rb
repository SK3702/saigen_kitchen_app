require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'バリデーションのテスト' do
    let(:recipe) { build(:recipe) }

    context '有効なデータの場合' do
      it '全ての必要な属性が揃っている場合、有効であること' do
        expect(recipe).to be_valid
      end
    end

    context 'タイトルのバリデーション' do
      it { should validate_presence_of(:title).with_message('を入力してください') }
      it { should validate_length_of(:title).is_at_most(30).with_message('は30文字以内で入力してください') }
    end

    context '作品名のバリデーション' do
      it { should validate_presence_of(:work_name).with_message('を入力してください') }
      it { should validate_length_of(:work_name).is_at_most(30).with_message('は30文字以内で入力してください') }
    end

    context '画像のバリデーション' do
      it { should validate_presence_of(:recipe_image).with_message('を入力してください') }
    end

    context 'ポイント・コツのバリデーション' do
      it { should validate_presence_of(:tip).with_message('を入力してください') }
      it { should validate_length_of(:tip).is_at_most(200).with_message('は200文字以内で入力してください') }
    end

    context '材料のバリデーション' do
      it '材料が少なくとも1つ必要なこと' do
        recipe.ingredients = []
        recipe.valid?
        expect(recipe.errors[:ingredients]).to include("を少なくとも1つ追加してください。")
      end
    end

    context '手順のバリデーション' do
      it '手順が少なくとも1つ必要なこと' do
        recipe.instructions = []
        recipe.valid?
        expect(recipe.errors[:instructions]).to include("を少なくとも1つ追加してください。")
      end
    end
  end

  describe 'アソシエーションのテスト' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
    it { should have_many(:ingredients).dependent(:destroy) }
    it { should have_many(:instructions).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:favorited_by).through(:favorites).source(:user) }
  end

  describe 'スコープのテスト' do
    let!(:older_recipe) { create(:recipe, created_at: 1.day.ago) }
    let!(:newer_recipe) { create(:recipe, created_at: Time.zone.now) }
    let(:user) { create(:user) }
    let!(:favorite) { create(:favorite, user_id: user.id, recipe_id: newer_recipe.id) }

    it 'recentスコープで新しい順に取得できること' do
      expect(Recipe.recent).to eq [newer_recipe, older_recipe]
    end

    it "more_favoritesで人気順に取得できること" do
      expect(Recipe.more_favorites).to eq [newer_recipe, older_recipe]
    end
  end

  describe "関数.searchのテスト" do
    let!(:recipe1) { create(:recipe, title: "レシピ1", work_name: "ab") }
    let!(:recipe2) { create(:recipe, title: "レシピ2", work_name: "ac") }
    let!(:recipe3) { create(:recipe, title: "テスト3", work_name: "bc") }
    let!(:recipe4) { create(:recipe, title: "レシピ4", work_name: "cd") }

    context "検索キーワードが入力されたとき" do
      it "全てのキーワードにマッチするレシピが取得できること" do
        results = Recipe.search("レシピ a")
        expect(results).to include(recipe1)
        expect(results).to include(recipe2)
        expect(results).not_to include(recipe3)
        expect(results).not_to include(recipe4)
      end

      it "キーワードにマッチするレシピがない場合、何も取得できないこと" do
        results = Recipe.search("nonexistent_keyword")
        expect(results).to be_empty
      end
    end

    context "検索キーワードが空欄の時" do
      it "noneを返すこと" do
        results = Recipe.search("")
        expect(results).to be_empty
      end
    end
  end
end
