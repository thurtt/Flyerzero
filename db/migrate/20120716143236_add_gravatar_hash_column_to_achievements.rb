class AddGravatarHashColumnToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :gravatar_hash, :string

    Achievement.find_each do |achievement|
	achievement.gravatar_hash = Digest::MD5.hexdigest(achievement.email.downcase)
	achievement.save
    end
  end
end
