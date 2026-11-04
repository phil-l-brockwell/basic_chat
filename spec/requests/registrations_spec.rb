require "rails_helper"

describe "Registrations", type: :request do
  let(:params) { { user: { email_address:, password:, password_confirmation: } } }

  let(:email_address) { "new@example.com" }
  let(:password) { "password" }
  let(:password_confirmation) { password }

  it "creates an account and signs the user in" do
    expect { post registration_path, params: params }.to change(User, :count).by(1)
    expect(response).to redirect_to(root_path)
    get root_path
    expect(response).to have_http_status(:ok)
  end

  context "when the password and password confirmation do not match" do
    let(:password_confirmation) { "different" }

    it "re-renders the form with errors for invalid details" do
      expect { post registration_path, params: params }.not_to change(User, :count)
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password confirmation doesn&#39;t match Password")
    end
  end
end
