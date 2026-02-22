class CreateMasterProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :master_products do |t|
      t.string :name
      t.string :sku
      t.decimal :price
      t.text :description
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
