require "rails_helper"

describe "Rooms", type: :request do
  let(:user) { create(:user) }

  before { sign_in_as user }

  describe "GET /" do
    context "when the user is in #basic" do
      before { get root_path }

      it "takes the user to #basic" do
        expect(response).to redirect_to(room_path(Room.default))
      end
    end

    context "when the user isn't in #basic" do
      before do
        user.user_rooms.destroy_all
        get root_path
      end

      it "says they aren't in any rooms" do
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("You're not in any rooms yet")
      end
    end
  end

  describe "GET /rooms/:id" do
    subject(:get_room) { get room_path(room) }

    context "for a room the user is in" do
      let(:room) { Room.default }

      before { create(:message, room:, body: "Earlier message") }

      it "shows its recent messages" do
        get_room

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Earlier message")
      end
    end

    context "for a room the user isn't in" do
      let(:room) { create(:room) }

      it "isn't found" do
        get_room

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
