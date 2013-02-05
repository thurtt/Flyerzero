class CreateVisitors < ActiveRecord::Migration
  def change
    create_table :visitors do |t|
      t.string :email
      t.string :name
      t.string :comment
      t.decimal :lat,  :precision => 15, :scale => 10
      t.decimal :lng,  :precision => 15, :scale => 10
      t.integer :event_id

      t.timestamps
    end
  end
end
