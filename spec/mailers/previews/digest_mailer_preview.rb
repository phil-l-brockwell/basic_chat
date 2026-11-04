class DigestMailerPreview < ActionMailer::Preview
  def weekly
    DigestMailer.weekly(User.first, as_of: Time.current)
  end
end
