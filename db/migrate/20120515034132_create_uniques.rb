class CreateUniques < ActiveRecord::Migration
  def change
    create_table :uniques do |t|
      t.string :hash

      t.timestamps
    end
  end
end
