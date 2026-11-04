class DigestMailer < ApplicationMailer
  helper :digest

  def weekly(user, as_of:)
    @digest = WeeklyDigest.new(user, as_of:)
    mail to: user.email_address
  end
end
