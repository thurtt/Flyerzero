class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :email
      t.date :expiry
      t.decimal :lat,  :precision => 15, :scale => 10
      t.decimal :lng,  :precision => 15, :scale => 10
      t.string :valdiation_hash
      t.integer :validated
      t.integer :event_id
      
      t.string :photo_file_name
      t.string :photo_content_type
      t.integer :photo_file_size

      t.timestamps
    end
  end
end
