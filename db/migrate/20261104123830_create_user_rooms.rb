class CreateUserRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :user_rooms do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.timestamps
    end

    add_index :user_rooms, [ :room_id, :user_id ], unique: true
  end
end
