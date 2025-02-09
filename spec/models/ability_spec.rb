require 'rails_helper'

RSpec.describe Ability, type: :model do
  let(:admin_user) { create(:user, admin: true) }
  let(:user) { create(:user, admin: false) }

  context "管理者ユーザーの場合" do
    it "RailsAdmin へのアクセスと全リソースの管理が可能である" do
      ability = Ability.new(admin_user)
      expect(ability.can?(:access, :rails_admin)).to be true
      expect(ability.can?(:manage, :all)).to be true
    end
  end

  context "一般ユーザーの場合" do
    it "RailsAdmin へのアクセスができない" do
      ability = Ability.new(user)
      expect(ability.can?(:access, :rails_admin)).to be false
    end
  end
end
