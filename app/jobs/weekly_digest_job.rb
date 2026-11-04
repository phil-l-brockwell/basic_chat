class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(as_of: Time.current)
    User.find_each do |user|
      DigestMailer.weekly(user, as_of:).deliver_later
    end
  end
end
