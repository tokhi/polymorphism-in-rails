class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :file_asset, foreign_key: true
      t.references :imageable, polymorphic: true, index: true
      t.timestamps null: false
    end
  end
end
