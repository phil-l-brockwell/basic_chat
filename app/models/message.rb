class Message < ApplicationRecord
  MAXIMUM_LENGTH = 1_000
  HISTORY_LENGTH = 50
  belongs_to :room
  belongs_to :user
  normalizes :body, with: ->(body) { body.strip }
  validates :body, presence: true, length: { maximum: MAXIMUM_LENGTH }
  scope :newest_first, -> { order(id: :desc) }
  after_create_commit -> { broadcast_append_to room, target: "messages" }
end
