require "rails_helper"

describe WeeklyDigest do
  subject(:digest) { described_class.new(user, as_of:) }

  let(:as_of) { Time.zone.parse("2026-02-09 09:00") }
  let(:user) { create(:user, created_at: Time.zone.parse("2026-01-01 12:00")) }
  let(:other) { create(:user) }
  let(:other_room) { create(:room) }

  def message(from, at, room: Room.default)
    create(:message, user: from, room:, created_at: Time.zone.parse(at))
  end

  describe "#messages_last_week" do
    before do
      message(other, "2026-02-02 08:59")
      message(other, "2026-02-02 09:00")
      message(user, "2026-02-05 10:00")
      message(other, "2026-02-09 09:00")
      message(other, "2026-02-09 09:01")
    end

    it "counts the messages in the user's rooms in the week before as_of, including their own" do
      expect(digest.messages_last_week).to eq(3)
    end

    context "with messages in a room the user isn't in" do
      before { message(other, "2026-02-05 10:00", room: other_room) }

      it "leaves them out" do
        expect(digest.messages_last_week).to eq(3)
      end
    end
  end

  describe "#messages_since_last_message" do
    context "when the user has posted" do
      before do
        message(user, "2026-01-20 10:00")
        message(other, "2026-01-25 10:00")
        message(user, "2026-02-01 10:00")
        message(other, "2026-02-03 10:00")
        message(other, "2026-02-08 10:00")
        message(other, "2026-02-10 10:00")
      end

      it "counts other people's messages since the user's last one" do
        expect(digest.last_message_at).to eq(Time.zone.parse("2026-02-01 10:00"))
        expect(digest.messages_since_last_message).to eq(2)
      end

      context "and posted again after as_of" do
        before { message(user, "2026-02-09 10:00") }

        it "still counts from their last message before as_of" do
          expect(digest.since).to eq(Time.zone.parse("2026-02-01 10:00"))
          expect(digest.messages_since_last_message).to eq(2)
        end
      end

      context "with messages in a room the user isn't in" do
        before { message(other, "2026-02-05 10:00", room: other_room) }

        it "leaves them out" do
          expect(digest.messages_since_last_message).to eq(2)
        end
      end
    end

    context "when the user has never posted" do
      before do
        message(other, "2025-12-31 10:00")
        message(other, "2026-01-15 10:00")
      end

      it "counts from when they joined" do
        expect(digest.last_message_at).to be_nil
        expect(digest.since).to eq(user.created_at)
        expect(digest.messages_since_last_message).to eq(1)
      end
    end
  end
end
