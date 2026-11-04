require "rails_helper"

describe "Scrolling the messages", type: :system do
  let(:user) { create(:user) }
  let(:room) { Room.default }
  let(:message_count) { 30 }

  def scroller
    "document.getElementById('messages_scroller')"
  end

  def distance_from_bottom
    page.evaluate_script("(e => e.scrollHeight - e.scrollTop - e.clientHeight)(#{scroller})")
  end

  before do
    message_count.times { |i| create(:message, room:, body: "Message #{i}") }

    visit new_session_path
    fill_in "Enter your email address", with: user.email_address
    fill_in "Enter your password", with: "password123"
    click_button "Sign in"
    expect(page).to have_text("Message #{message_count - 1}")
    expect(page.evaluate_script("(e => e.scrollHeight > e.clientHeight)(#{scroller})")).to be(true)
  end

  it "starts at the newest message" do
    expect(distance_from_bottom).to be < 5
  end

  context "when a message arrives" do
    before do
      create(:message, room:, body: "Just arrived")
      expect(page).to have_text("Just arrived")
    end

    it "scrolls to it" do
      expect(distance_from_bottom).to be < 5
    end
  end

  context "with more messages than fit in one page" do
    let(:message_count) { Message::HISTORY_LENGTH + 10 }

    it "only shows the newest page at first" do
      expect(page).to have_text("Message 10")
      expect(page).to have_no_text("Message 9")
    end

    context "when scrolling to the top" do
      before { page.execute_script("#{scroller}.scrollTop = 0") }

      it "loads the older messages above, oldest first" do
        expect(page).to have_text("Message 0")
        expect(page.text).to match(/Message 0\b.*Message 9\b.*Message 10\b/m)
      end
    end
  end
end
