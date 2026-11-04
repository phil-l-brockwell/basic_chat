class User < ApplicationRecord
  MINIMUM_PASSWORD_LENGTH = 8
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_rooms, dependent: :destroy
  has_many :rooms, through: :user_rooms
  has_many :messages, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: MINIMUM_PASSWORD_LENGTH }, allow_nil: true
  after_create :join_default_room

  def default_room
    rooms.find_by(name: Room::DEFAULT_NAME)
  end

  private

  def join_default_room
    user_rooms.create!(room: Room.default)
  end
end
