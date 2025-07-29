class CreateReservationDates < ActiveRecord::Migration[8.0]
  def change
    create_table :reservation_dates do |t|
      t.date :reservation_at, null: false, index: { unique: true }
      t.integer :reservation_count, default: 0, null: false
      t.integer :lock_version, default: 0, null: false

      t.timestamps
    end
  end
end
