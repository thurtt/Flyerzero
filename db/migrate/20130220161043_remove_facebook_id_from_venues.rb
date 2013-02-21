class RemoveFacebookIdFromVenues < ActiveRecord::Migration
  def up
    remove_column :venues, :facebook_id
  end

  def down
    add_column :venues, :facebook_id, :string
  end
end
