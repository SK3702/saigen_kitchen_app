require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe) }
  let!(:comment) { create(:comment, recipe: recipe, user: user) }
  let!(:other_comment) { create(:comment, recipe: recipe, user: other_user) }
  let(:valid_attribute) { { content: "テストコメント" } }
  let(:invalid_attributes) { { content: "" } }

  describe "コメント投稿" do
    describe "POST /recipes/:recipe_id/comments" do
      context "ログイン済みの場合" do
        before { sign_in user }

        context "有効なパラメータの場合" do
          it "コメントが作成されること" do
            expect { post recipe_comments_path(recipe), params: { comment: valid_attribute } }.to change(Comment, :count).by(1)
            expect(response).to redirect_to(recipe_path(recipe))
          end
        end

        context "無効なパラメータの場合" do
          it "コメント作成に失敗し、メッセージが表示されること" do
            expect { post recipe_comments_path(recipe), params: { comment: invalid_attributes } }.not_to change(Comment, :count)
            expect(response).to redirect_to(recipe_path(recipe))
            follow_redirect!
            expect(response.body).to include("を入力してください")
          end
        end
      end

      context "未ログインユーザーの場合" do
        it "ログインページにリダイレクトされること" do
          expect { post recipe_comments_path(recipe), params: { comment: valid_attribute } }.not_to change(Comment, :count)
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end

  describe "コメント削除" do
    describe "DELETE /recipes/:recipe_id/comments/:id" do
      context "ログインしている場合" do
        before { sign_in user }

        it "コメントを削除できること" do
          expect { delete recipe_comment_path(recipe, comment) }.to change(Comment, :count).by(-1)
          expect(response).to redirect_to(recipe_path(recipe))
        end

        context "他ユーザーのコメントの場合" do
          it "コメントを削除できないこと" do
            expect { delete recipe_comment_path(recipe, other_comment) }.not_to change(Comment, :count)
            expect(response).to redirect_to(recipe_path(recipe))
            follow_redirect!
            expect(response.body).to include("自分のコメント以外の編集・削除はできません。")
          end
        end
      end

      context "ログインしていない場合" do
        it "ログインページにリダイレクトされること" do
          expect { delete recipe_comment_path(recipe, comment) }.not_to change(Comment, :count)
          expect(response).to redirect_to new_user_session_path
        end
      end
    end
  end
end
