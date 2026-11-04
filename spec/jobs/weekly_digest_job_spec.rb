require "rails_helper"

describe WeeklyDigestJob, type: :job do
  let!(:alice) { create(:user) }
  let!(:bob) { create(:user) }

  it "emails every user, counting up to the same moment" do
    freeze_time do
      expect { described_class.perform_now }
        .to have_enqueued_mail(DigestMailer, :weekly).with(alice, as_of: Time.current)
        .and have_enqueued_mail(DigestMailer, :weekly).with(bob, as_of: Time.current)
        .and have_enqueued_mail(DigestMailer, :weekly).exactly(2).times
    end
  end
end
