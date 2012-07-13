class ZeroboxController < ApplicationController
  def index

  end

  def promoter
    	  # Promoter: slideshow all promoter events, or just ones coming up
	  # promoter_id
	  # all

	  # sanity check
	  if !params[:promoter_id] or !params[:size] or !params[:all]
		# not ok
	  end

	  promoter_id = params[:promoter_id]
	  all = params[:all]
	  @size = params[:size]

	  email = Achievement.find(promoter_id).email
	  @flyers = Event.where(:email=>email).where('validated > 0').order('expiry') if all
	  @flyers = Event.where(:email=>email).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry') if !all
	  render :template=>"zerobox/slideshow"

  end


  def venue
	  # Venue: Show all upcoming shows at a venue
	  # foursqaure venue id
	  if !params[:venue_id] or !params[:size]
		# broken
	  end

	  @size = params[:size]
	  venue_id = params[:venue_id]
	  @flyers = Event.where(:venue_id=>venue_id).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	  render :template=>"zerobox/slideshow"
  end


  def box

	  # Zero Box, etc: Show all upcoming events within a certain radius
	  # radius if no venue id
	  # ll if no venue id
	  if !params[:ll] or !params[:radius] or !params[:size]
		# uh oh
	  end

	  ll = params[:ll]
	  radius = params[:radius]
	  @size = params[:size]

	  @flyers = Event.within(radius, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	  render :template=>"zerobox/slideshow"
  end
end
