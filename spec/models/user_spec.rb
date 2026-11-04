require "rails_helper"

describe User, type: :model do
  subject(:user) { create(:user) }

  describe "#default_room" do
    context "when the user is in #basic" do
      it "returns it" do
        expect(user.default_room).to eq(Room.default)
      end
    end

    context "when the user isn't in #basic" do
      before { user.user_rooms.destroy_all }

      it "returns nil" do
        expect(user.default_room).to be_nil
      end
    end
  end
end
