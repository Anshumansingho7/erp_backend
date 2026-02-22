class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :shop, null: false, foreign_key: true
      t.decimal :total_amount, null: false, default: 0
      t.string :customer_name, null: false
      t.string :customer_phone, null: false

      t.timestamps
    end
  end
end
