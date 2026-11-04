require "rails_helper"
describe "Sessions", type: :request do
  let(:user) { create(:user) }

  context "when not signed in" do
    it "redirects to the sign-in page" do
      get root_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signed in" do
    before { sign_in_as user }

    it "redirects to the root page" do
      expect(response).to redirect_to(root_url)
      get room_path(Room.default)
      expect(response).to have_http_status(:ok)
    end
  end

  context "when signing in with the wrong password" do
    before { sign_in_as user, password: "wrong-password" }

    it "redirects to the sign-in page" do
      expect(response).to redirect_to(new_session_path)
      get root_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "when signing out" do
    before do
      sign_in_as user
      delete session_path
      get root_path
    end

    it "redirects to the sign-in page" do
      expect(response).to redirect_to(new_session_path)
    end
  end
end
