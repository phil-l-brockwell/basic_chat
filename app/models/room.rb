class Room < ApplicationRecord
  DEFAULT_NAME = "basic"
  has_many :user_rooms, dependent: :destroy
  has_many :users, through: :user_rooms
  has_many :messages, dependent: :destroy
  normalizes :name, with: ->(name) { name.strip.downcase }
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers and hyphens" }

  def self.default
    find_or_create_by!(name: DEFAULT_NAME)
  end
end
