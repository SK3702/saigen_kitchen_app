require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションのテスト" do
    let(:user) { create(:user) }

    it "ユーザーネーム、メールアドレス、パスワードがある場合、有効であること" do
      expect(user).to be_valid
    end

    context "名前のバリデーション" do
      it { should validate_presence_of(:name).with_message("を入力してください") }
    end
    context "emailのバリデーション" do
      it { should validate_presence_of(:email).with_message("を入力してください") }
      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message("はすでに存在します") }
      it "メールアドレスが正しい形式でない場合、登録できないこと" do
        user.email = "invalid-email"
        user.valid?
        expect(user.errors[:email]).to include "は不正な値です"
      end
    end
    context "パスワードのバリデーション" do
      it { should validate_presence_of(:password).with_message("を入力してください") }
      it { is_expected.to validate_length_of(:password).is_at_least(6).with_message("は6文字以上で入力してください") }
      it { is_expected.to validate_confirmation_of(:password).with_message("とパスワードの入力が一致しません") }
    end
    context "自己紹介のバリデーション" do
      it { should validate_length_of(:bio).is_at_most(200).with_message("は200文字以内で入力してください") }
    end

    describe "アバターの更新" do
      it "正しい拡張子で、ユーザーがavatarを更新できること" do
        updated_image = Rack::Test::UploadedFile.new(image_file_path("test_image.png"), "image/png")
        user = build(:user, avatar: updated_image)
        expect(user).to be_valid
      end

      it "不正な拡張子では、ユーザーがavatarを更新できないこと" do
        updated_image = Rack::Test::UploadedFile.new(image_file_path("invalid_image.txt"), "text/plain")
        user = build(:user, avatar: updated_image)
        user.valid?
        expect(user.errors[:avatar]).to include "は許可されていない拡張子です。"
      end
    end
  end

  describe "アソシエーションのテスト" do
    it { should have_many(:recipes) }
  end
end
