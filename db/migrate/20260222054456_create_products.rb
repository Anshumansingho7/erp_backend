class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :master_product, null: false, foreign_key: true
      t.references :shop, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :discount, null: false, default: 0

      t.timestamps
    end
  end
end
