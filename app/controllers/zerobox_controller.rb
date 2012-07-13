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
	  
	  template = "zerobox/slideshow"
	  
	  if params[:calendar] == "1"
	  	  template = "zerobox/calendar"
	  end

	  promoter_id = params[:promoter_id]
	  all = params[:all]
	  @size = params[:size]

	  email = Achievement.find(promoter_id).email
	  @flyers = Event.where(:email=>email).where('validated > 0').order('expiry') if all
	  @flyers = Event.where(:email=>email).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry') if !all
	  render :template=>template

  end
  
  def calendar
  	  
  	  if !params[:size]
  	  	  #not ok
  	  end
	  all = params[:all]
	  @size = params[:size]
  	  
  	  if params[:promoter_id]
  	  	  promoter_id = params[:promoter_id]
  	  	  refresh_url = "/zerobox/calendar?promoter_id=" + params[:promoter_id] + "&size=" + params[:size]
	
		  email = Achievement.find(promoter_id).email
		  @flyers = Event.where(:email=>email).where('validated > 0').order('expiry') if all
		  @flyers = Event.where(:email=>email).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry') if !all
	  end
	  
	  if params[:venue_id]
		venue_id = params[:venue_id]
		refresh_url = "/zerobox/calendar?venue_id=" + params[:venue_id] + "&size=" + params[:size]
		@flyers = Event.where(:venue_id=>venue_id).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	  end
	  
	  if params[:ll]
	  	  ll = params[:ll]
  	  	  refresh_url = "/zerobox/calendar?ll=" + params[:ll] + "&size=" + params[:size] + "&radius=" + params[:radius]
	  	  radius = params[:radius]
	  	  @flyers = Event.within(radius, :origin => ll).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry')
	  end
	  
	  respond_to do |format|
	  	  format.html { render :template=>"zerobox/calendar", :locals=>{:refresh_url=>refresh_url}}
	  	  format.json { render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info]) }
	  end
	  
	  
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
