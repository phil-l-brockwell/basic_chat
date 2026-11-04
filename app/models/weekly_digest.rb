class WeeklyDigest
  attr_reader :user, :as_of

  def initialize(user, as_of: Time.current)
    @user = user
    @as_of = as_of
  end

  def messages_last_week
    created_at = (as_of - 1.week)..as_of
    messages.where(created_at:).count
  end

  def messages_since_last_message
    messages.where.not(user:).where(created_at: since..as_of).count
  end

  def last_message_at
    @last_message_at ||= user.messages.where(created_at: ..as_of).maximum(:created_at)
  end

  def since
    last_message_at || user.created_at
  end

  private

  def messages
    Message.where(room: user.rooms)
  end
end
