require "rails_helper"

describe "Messages", type: :request do
  subject(:post_message) { post room_messages_path(room), params: { message: { body: } }, as: :turbo_stream }

  let(:user) { create(:user) }
  let(:room) { Room.default }
  let(:body) { "Hello" }

  context "when not signed in" do
    it "redirects to the sign-in page" do
      post_message

      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in" do
    before { sign_in_as user }

    context "with a valid message" do
      it "saves it from the current user in the room" do
        expect { post_message }.to change(room.messages.where(user:), :count).by(1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "with a blank message" do
      let(:body) { "  " }

      it "shows the errors without saving it" do
        expect { post_message }.not_to change(Message, :count)
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("Body can&#39;t be blank")
      end
    end

    context "in a room the user isn't in" do
      let(:room) { create(:room) }

      it "isn't allowed" do
        expect { post_message }.not_to change(Message, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "loading older messages" do
    context "in a room the user isn't in" do
      let(:room) { create(:room) }

      before do
        sign_in_as user
        get room_messages_path(room, format: :turbo_stream)
      end

      it "isn't found" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
