class CreateShops < ActiveRecord::Migration[8.0]
  def change
    create_table :shops do |t|
      t.string :name
      t.text :address
      t.string :phone
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
