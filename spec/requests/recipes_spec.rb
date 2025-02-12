require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let!(:recipe) { create(:recipe, user_id: user.id) }
  let(:valid_attributes) do
    recipe = build(:recipe, user: user, category: category)
    recipe.attributes.merge(
      ingredients_attributes: [
        { name: '卵', quantity: '2個' },
        { name: '砂糖', quantity: '50g' },
      ],
      instructions_attributes: [
        { description: '卵を割る' },
        { description: '砂糖を加える' },
      ]
    )
  end
  let(:other_user) { create(:user) }
  let(:other_user_recipe) { create(:recipe, user: other_user) }

  before { sign_in user }

  describe "レシピ投稿" do
    describe "GET /recipes/new" do
      context "ログイン済みの場合" do
        before { get new_recipe_path }

        it "レスポンスが正常であること" do
          expect(response).to have_http_status(200)
        end

        it "レシピ投稿フォームが含まれていること" do
          expect(response.body).to include("レシピタイトル", "作品名", "カテゴリー",
            "料理画像", "ポイント・コツ", "材料名", "分量", "手順")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          get new_recipe_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "POST /recipes" do
      context "有効なパラメータの場合" do
        it "レシピが作成されること" do
          expect { post recipes_path, params: { recipe: valid_attributes } }.to change(Recipe, :count).by(1)
          expect(response).to redirect_to(recipe_path(Recipe.last))
        end
      end

      context "無効なパラメータの場合" do
        it "無効なデータではレシピ作成に失敗すること" do
          invalid_attributes = {
            title: "",
            work_name: "",
            category_id: nil,
            tip: "",
            recipe_image: "",
            ingredients_attributes: [
              { name: "", quantity: "" },
            ],
            instructions_attributes: [
              { description: "" },
            ],
          }
          expect { post recipes_path, params: { recipe: invalid_attributes } }.not_to change(Recipe, :count)
          expect(response.body).to include("を入力してください")
          expect(response.body).to include("を少なくとも1つ追加してください。")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          post recipes_path, params: { recipe: valid_attributes }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "レシピ詳細ページ" do
    describe "GET /recipes" do
      before { get recipe_path(recipe) }

      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "recipeの情報が含まれており、他のrecipeの情報が含まれていないこと" do
        other_recipe = create(:recipe, title: "test_recipe2", user_id: user.id)
        expect(response.body).to include(
          recipe.title,
          recipe.work_name,
          recipe.category.name,
          "src=\"#{recipe.recipe_image.url}\"",
          recipe.tip,
          recipe.ingredients.first.name,
          recipe.ingredients.first.quantity,
          recipe.instructions.first.step.to_s,
          recipe.instructions.first.description,
          recipe.work_title,
          recipe.work_author,
          recipe.work_image,
          recipe.work_price.to_s,
          recipe.work_url
        )
        expect(response.body).not_to include(other_recipe.title)
      end

      it "お気に入りボタンが含まれていること" do
        expect(response.body).to include("お気に入り")
      end
    end
  end

  describe "レシピ編集" do
    describe "GET /recipes/edit" do
      context "ログイン済みの場合" do
        before { get edit_recipe_path(recipe) }

        it "レスポンスが正常であること" do
          expect(response).to have_http_status(200)
        end

        it "レシピ情報編集フォームが含まれていること" do
          expect(response.body).to include("レシピタイトル", "作品名", "カテゴリー",
            "料理画像", "ポイント・コツ", "材料名", "分量", "手順")
        end
      end

      context "他のユーザーのレシピの場合" do
        it "アクセスが拒否されること" do
          get edit_recipe_path(other_user_recipe)
          expect(response).to redirect_to(profile_path(user))
          expect(flash[:alert]).to include("自分のレシピ以外の編集・削除はできません。")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          get edit_recipe_path(recipe)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "PATCH /recipes" do
      context "有効なパラメータの場合" do
        it "レシピ情報更新に成功すること" do
          updated_image = Rack::Test::UploadedFile.new(image_file_path("test_image.png"), "image/png")
          updated_category = create(:category)

          updated_attributes = {
            title: "test_recipe2",
            work_name: "test_book2",
            category_id: updated_category.id,
            tip: "難しい",
            recipe_image: updated_image,
            ingredients_attributes: [
              { name: "うどん", quantity: "1玉" },
            ],
            instructions_attributes: [
              { description: "うどんを茹でる。" },
            ],
            work_title: "updated_title",
            work_author: "updated_author",
            work_image: "https://updated-example.png",
            work_price: 2000,
            work_url: "https://updated-example.com",
          }
          patch recipe_path(recipe), params: { recipe: updated_attributes }
          expect(response).to redirect_to(recipe_path(recipe))
        end
      end

      context "無効なパラメータの場合" do
        it "レシピ情報更新に失敗すること" do
          invalid_image = Rack::Test::UploadedFile.new(image_file_path("invalid_image.txt"), "text/plain")
          invalid_attributes = {
            title: "",
            work_name: "",
            category_id: nil,
            tip: "",
            recipe_image: invalid_image,
          }
          patch recipe_path(recipe), params: { recipe: invalid_attributes }
          expect(response.body).to include("を入力してください")
          expect(response.body).to include("は許可されていない拡張子です。")
        end
      end

      context "他のユーザーのレシピの場合" do
        it "レシピ情報更新に失敗すること" do
          patch recipe_path(other_user_recipe), params: { recipe: valid_attributes }
          expect(response).to redirect_to(profile_path(user))
          expect(flash[:alert]).to include("自分のレシピ以外の編集・削除はできません。")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          patch recipe_path(recipe), params: { recipe: valid_attributes }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "レシピ削除" do
    describe "DELETE /recipes" do
      context "ログイン済みの場合" do
        it "レシピが削除されること" do
          recipe = create(:recipe, user_id: user.id)
          expect { delete recipe_path(recipe) }.to change(Recipe, :count).by(-1)
          expect(response).to redirect_to(profile_path(user))
        end
      end

      context "他のユーザーのレシピの場合" do
        it "レシピ削除に失敗すること" do
          delete recipe_path(other_user_recipe)
          expect(response).to redirect_to(profile_path(user))
          expect(flash[:alert]).to include("自分のレシピ以外の編集・削除はできません。")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          delete recipe_path(recipe)
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "お気に入りレシピページ" do
    describe "GET /recipes/favorites" do
      before { get favorites_recipes_path }
      let!(:favorite) { create(:favorite, user_id: user.id, recipe_id: other_user_recipe.id) }

      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "見出しのお気に入りレシピ一覧が含まれていること" do
        expect(response.body).to include("お気に入りレシピ一覧")
      end

      context "お気に入りレシピがある場合" do
        it "お気に入りレシピの情報が含まれていること" do
          get favorites_recipes_path

          expect(response.body).to include(
            other_user_recipe.title,
            other_user_recipe.work_name,
            "src=\"#{other_user_recipe.recipe_image.thumb.url}\"",
            "src=\"#{other_user.avatar.smaller.url}\"",
          )
        end
      end

      context "お気に入りのレシピがない場合" do
        it "レシピ情報が含まれていないこと" do
          expect(response.body).to include("お気に入りのレシピはまだありません。")
        end
      end
    end
  end

  describe "検索機能" do
    describe "GET /recipes/search" do
      let!(:recipe1) { create(:recipe, title: "レシピ1", work_name: "ab") }
      let!(:recipe2) { create(:recipe, title: "テスト2", work_name: "bc") }

      context "検索キーワードが存在する場合" do
        it "キーワードにマッチするデータを返すこと" do
          get search_recipes_path, params: { keyword: "レシピ ab" }

          expect(response).to have_http_status(200)
          expect(response.body).to include("レシピ1")
          expect(response.body).to include("ab")
          expect(response.body).not_to include("テスト2")
        end
      end

      context "検索キーワードが空白の場合" do
        it "何もデータを返さないこと" do
          get search_recipes_path, params: { keyword: "" }

          expect(response).to have_http_status(200)
          expect(response.body).not_to include("レシピ1")
          expect(response.body).not_to include("テスト2")
        end
      end
    end

    describe "GET /recipes/work_search" do
      let(:valid_keyword) { "本" }

      let(:book_result) do
        instance_double(
          RakutenWebService::Books::Book,
          isbn: "1234567890",
          title: "テストブックタイトル",
          large_image_url: "http://example.com/book.jpg",
          author: "テスト著者",
          item_price: 1500,
          item_url: "http://example.com/book"
        )
      end
      let(:dvd_result) do
        instance_double(
          RakutenWebService::Books::DVD,
          jan: "0987654321",
          title: "テストDVDタイトル",
          large_image_url: "http://example.com/dvd.jpg",
          label: "テストレーベル",
          item_price: 2500,
          item_url: "http://example.com/dvd"
        )
      end

      before do
        allow(RakutenWebService::Books::Total).to receive(:search).
          with(keyword: valid_keyword).
          and_return([book_result, dvd_result])

        allow(book_result).to receive(:is_a?) do |genre|
          genre == RakutenWebService::Books::Book
        end
        allow(dvd_result).to receive(:is_a?) do |genre|
          genre == RakutenWebService::Books::DVD
        end
      end

      it "パラメータが存在すればリクエストが正常であること" do
        get work_search_recipes_path, xhr: true, params: { keyword: valid_keyword }
        expect(response).to have_http_status(200)
      end

      it "レスポンスがJSON形式で返却され、期待するキーを含んでいること" do
        get work_search_recipes_path, xhr: true, params: { keyword: valid_keyword }
        json = JSON.parse(response.body)
        expect(json.first).to include("id", "title", "author", "image_url", "price", "url", "type")
      end
    end
  end
end
