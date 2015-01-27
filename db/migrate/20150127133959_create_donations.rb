class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.string :name
      t.string :email
      t.decimal :amount
      t.string :payment_token

      t.timestamps
    end
  end
end
