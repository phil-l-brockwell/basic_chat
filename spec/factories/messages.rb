FactoryBot.define do
  factory :message do
    room { Room.default }
    user
    body { "Hello, world" }
  end
end
