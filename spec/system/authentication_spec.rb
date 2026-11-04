require "rails_helper"

describe "Authentication", type: :system do
  let(:email_address) { "alice@example.com" }
  let(:password) { "password123" }

  before do
    visit new_registration_path
    fill_in "Enter your email address", with: email_address
    fill_in "Choose a password (at least #{User::MINIMUM_PASSWORD_LENGTH} characters)", with: password
    fill_in "Repeat your password", with: password
    click_button "Sign up"
  end

  it "lets a new user sign up, sign out and sign back in" do
    expect(page).to have_text("Welcome to Basic Chat!")
    expect(page).to have_css("#current_user", text: email_address)

    click_on "Sign out"
    expect(page).to have_button("Sign in")

    fill_in "Enter your email address", with: email_address
    fill_in "Enter your password", with: password
    click_button "Sign in"
    expect(page).to have_css("#current_user", text: email_address)
  end
end
