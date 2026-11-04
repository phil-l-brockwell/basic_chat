require "rails_helper"

describe UserRoom, type: :model do
  subject(:user_room) { build(:user_room, user:, room:) }

  let(:user) { create(:user) }
  let(:room) { create(:room) }

  context "when the user isn't in the room yet" do
    it "is valid" do
      expect(user_room).to be_valid
    end
  end

  context "when the user is already in the room" do
    before { create(:user_room, user:, room:) }

    it "is invalid" do
      expect(user_room).not_to be_valid
      expect(user_room.errors[:user_id]).to include("has already been taken")
    end
  end
end
