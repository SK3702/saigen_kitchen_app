require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe "バリデーションのテスト" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
    it { should validate_length_of(:message).is_at_most(1000) }
  end
end
