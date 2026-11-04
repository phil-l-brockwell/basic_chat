require "rails_helper"

describe DigestMailer, type: :mailer do
  describe "#weekly" do
    subject(:mail) { described_class.weekly(user, as_of:) }

    let(:as_of) { Time.zone.parse("2026-02-09 09:00") }
    let(:user) { create(:user, created_at: Time.zone.parse("2026-01-01 12:00")) }
    let(:other) { create(:user) }
    let(:text) { mail.text_part.body.to_s }
    let(:html) { mail.html_part.body.to_s }

    def message(from, at)
      create(:message, user: from, created_at: Time.zone.parse(at))
    end

    around { |example| travel_to(as_of) { example.run } }

    it "is sent to the user" do
      expect(mail.to).to eq([ user.email_address ])
      expect(mail.subject).to eq("Your week on Basic Chat")
    end

    context "when the user has posted" do
      before do
        message(other, "2026-01-31 10:00")
        message(user, "2026-02-03 10:00")
        3.times { message(other, "2026-02-05 10:00") }
      end

      it "reports the week's total and the count since their last message" do
        [ text, html ].each do |body|
          expect(body).to include("4 messages have been exchanged in the last week.")
          expect(body).to include("3 since your last message on the 3rd of February.")
        end
      end
    end

    context "with one message in the week" do
      before { message(user, "2026-02-03 10:00") }

      it "uses the singular" do
        expect(text).to include("1 message has been exchanged in the last week.")
      end
    end

    context "when the user has never posted" do
      before { message(other, "2026-01-10 10:00") }

      it "counts from when they joined" do
        expect(text).to include("1 since you joined on the 1st of January.")
      end
    end

    context "when the date is in a previous year" do
      let(:user) { create(:user, created_at: Time.zone.parse("2025-11-22 12:00")) }

      it "includes the year" do
        expect(text).to include("0 since you joined on the 22nd of November 2025.")
      end
    end
  end
end
