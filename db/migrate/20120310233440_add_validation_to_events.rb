class AddValidationToEvents < ActiveRecord::Migration
  def change
  	  remove_column :events, :valdiation_hash
  	  add_column :events, :validation_hash, :string
  end
end
