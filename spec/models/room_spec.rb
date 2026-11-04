require "rails_helper"

describe Room, type: :model do
  subject(:room) { build(:room, name:) }

  let(:name) { "general" }

  describe "validations" do
    context "with lowercase letters, numbers and hyphens in the name" do
      let(:name) { "team-2" }

      it "is valid" do
        expect(room).to be_valid
      end
    end

    context "with other characters in the name" do
      let(:name) { "team 2" }

      it "is invalid" do
        expect(room).not_to be_valid
        expect(room.errors[:name]).to include("can only contain lowercase letters, numbers and hyphens")
      end
    end

    context "when the name is taken, ignoring case" do
      let(:name) { "General" }

      before { create(:room, name: "general") }

      it "is invalid" do
        expect(room).not_to be_valid
        expect(room.errors[:name]).to include("has already been taken")
      end
    end
  end

  context "with whitespace and capitals in the name" do
    let(:name) { "  General " }

    it "normalises it" do
      expect(room.name).to eq("general")
    end
  end

  describe ".default" do
    context "when #basic doesn't exist yet" do
      it "creates it" do
        expect { Room.default }.to change(Room, :count).by(1)
        expect(Room.default.name).to eq("basic")
      end
    end

    context "when #basic already exists" do
      let!(:basic) { Room.default }

      it "returns it without creating another" do
        expect { Room.default }.not_to change(Room, :count)
        expect(Room.default).to eq(basic)
      end
    end
  end
end
