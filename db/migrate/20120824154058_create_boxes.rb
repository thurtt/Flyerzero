class CreateBoxes < ActiveRecord::Migration
  def change
    create_table :boxes do |t|
      t.string :name
      t.string :idhash
      t.text :config
      t.datetime :lasthit

      t.timestamps
    end
  end
end
