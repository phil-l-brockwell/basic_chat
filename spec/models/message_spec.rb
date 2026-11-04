require "rails_helper"

describe Message, type: :model do
  subject(:message) { build(:message, body:) }

  let(:body) { "Hello" }

  describe "validations" do
    context "with a blank body" do
      let(:body) { "   " }

      it "is invalid" do
        expect(message).not_to be_valid
        expect(message.errors[:body]).to include("can't be blank")
      end
    end

    context "with a body of #{Message::MAXIMUM_LENGTH} characters" do
      let(:body) { "a" * Message::MAXIMUM_LENGTH }

      it "is valid" do
        expect(message).to be_valid
      end
    end

    context "with a body over #{Message::MAXIMUM_LENGTH} characters" do
      let(:body) { "a" * (Message::MAXIMUM_LENGTH + 1) }

      it "is invalid" do
        expect(message).not_to be_valid
        expect(message.errors[:body]).to include("is too long (maximum is #{Message::MAXIMUM_LENGTH} characters)")
      end
    end
  end

  context "with whitespace around the body" do
    let(:body) { "  hi  " }

    it "strips it" do
      expect(message.body).to eq("hi")
    end
  end

  describe ".newest_first" do
    let!(:oldest) { create(:message) }
    let!(:middle) { create(:message) }
    let!(:newest) { create(:message) }

    it "returns the newest messages first" do
      expect(Message.newest_first).to eq([ newest, middle, oldest ])
    end
  end

  describe "saving" do
    let(:room) { create(:room) }
    let(:body) { "Broadcast me" }

    it "broadcasts the message to its room" do
      expect { create(:message, room:, body:) }
        .to have_broadcasted_to(room.to_gid_param).with(a_string_including("Broadcast me"))
    end
  end
end
