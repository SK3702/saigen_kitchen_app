require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { create(:user) }

    context "登録成功" do
      it "ユーザーネーム、メールアドレス、パスワードがある場合、有効であること" do
        expect(user).to be_valid
      end
    end

    context "登録失敗" do
      it "名前がない場合、登録できないこと" do
        user.name = nil
        user.valid?
        expect(user.errors[:name]).to include "を入力してください"
      end

      it "メールアドレスがない場合、登録できないこと" do
        user.email = nil
        user.valid?
        expect(user.errors[:email]).to include "を入力してください"
      end

      it "メールアドレスが重複している場合、登録できないこと" do
        another_user = build(:user, email: user.email)
        another_user.valid?
        expect(another_user.errors[:email]).to include "はすでに存在します"
      end

      it "メールアドレスが正しい形式でない場合、登録できないこと" do
        user.email = "invalid-email"
        user.valid?
        expect(user.errors[:email]).to include "は不正な値です"
      end

      it "パスワードがない場合、登録できないこと" do
        user.password = nil
        user.valid?
        expect(user.errors[:password]).to include "を入力してください"
      end

      it "パスワードが5文字以下の場合、登録できないこと" do
        user.password = "test"
        user.valid?
        expect(user.errors[:password]).to include "は6文字以上で入力してください"
      end

      it "確認用パスワードがパスワードと異なる場合、登録できないこと" do
        user.password_confirmation = "another-testuser"
        user.valid?
        expect(user.errors[:password_confirmation]).to include "とパスワードの入力が一致しません"
      end
    end

    context "アバターの更新" do
      it "不正な拡張子では、ユーザーがavatarを更新できないこと" do
        updated_image = Rack::Test::UploadedFile.new(image_file_path("invalid_image.txt"), "text/plain")
        user = build(:user, avatar: updated_image)
        user.valid?
        expect(user.errors[:avatar]).to include "は許可されていない拡張子です"
      end
    end
  end
end
