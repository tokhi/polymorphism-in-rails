class CreateFileAssets < ActiveRecord::Migration
  def change
    create_table :file_assets do |t|
      t.string :path
      t.string :content_type
      t.string :permission
      t.string :filename

      t.timestamps null: false
    end
  end
end