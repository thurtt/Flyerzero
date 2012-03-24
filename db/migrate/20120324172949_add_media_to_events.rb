class AddMediaToEvents < ActiveRecord::Migration
  def change
    add_column :events, :media, :text
  end
end
