class Achievement < ActiveRecord::Base
	validates_presence_of :email
	
	def complete( pts = 1 )
		self.points = 0 if self.points == nil
		self.currency = 0 if self.currency == nil
		self.points += pts
		self.currency += pts
	end
end
