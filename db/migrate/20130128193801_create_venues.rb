class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :lat
      t.string :lng
      t.string :foursquare_id
      t.string :facebook_id

      t.timestamps
    end
  end
end
