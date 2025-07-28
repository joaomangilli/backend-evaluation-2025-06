class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :price_token, null: false
      t.string :payment_token, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.integer :amount, null: false
      t.integer :status, null: false

      t.timestamps
    end

    add_index :reservations, [ :user_id, :price_token, :payment_token ], unique: true
  end
end
