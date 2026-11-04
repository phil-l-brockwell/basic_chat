require "rails_helper"

describe "Messages", type: :system do
  let(:alice) { create(:user, email_address: "alice@example.com") }
  let(:bob) { create(:user, email_address: "bob@example.com") }

  def sign_in(user)
    visit new_session_path
    fill_in "Enter your email address", with: user.email_address
    fill_in "Enter your password", with: "password123"
    click_button "Sign in"
    expect(page).to have_css("#current_user", text: user.email_address)
  end

  context "when someone sends a message" do
    before do
      using_session(:bob) { sign_in bob }

      using_session(:alice) do
        sign_in alice
        fill_in "Message", with: "Hi Bob!"
        click_button "Send"
      end
    end

    it "shows it to the sender and clears the form" do
      using_session(:alice) do
        within("#messages") { expect(page).to have_text("Hi Bob!") }
        expect(page).to have_field("Message", with: "")
      end
    end

    it "shows it to everyone else without a reload" do
      using_session(:bob) do
        within("#messages") do
          expect(page).to have_text("alice@example.com")
          expect(page).to have_text("Hi Bob!")
        end
      end
    end
  end

  context "when arriving in the room" do
    before do
      create(:message, user: bob, body: "Sent before Alice arrived")
      sign_in alice
    end

    it "shows earlier messages" do
      within("#messages") { expect(page).to have_text("Sent before Alice arrived") }
    end
  end
end
