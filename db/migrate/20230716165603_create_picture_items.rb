class CreatePictureItems < ActiveRecord::Migration
  def change
    create_table :picture_items do |t|
      t.integer :user_id
      t.string :url

      t.timestamps
    end
  end
end
