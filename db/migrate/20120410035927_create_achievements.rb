class CreateAchievements < ActiveRecord::Migration
  def change
    create_table :achievements do |t|
      t.string :email
      t.integer :points
      t.integer :currency

      t.timestamps
    end
  end
end
