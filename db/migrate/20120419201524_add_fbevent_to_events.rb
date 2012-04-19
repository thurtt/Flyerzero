class AddFbeventToEvents < ActiveRecord::Migration
  def change
    add_column :events, :fbevent, :string
  end
end
