class AddVenueIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :venue_id, :string
  end
end
