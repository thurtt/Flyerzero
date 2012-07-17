class ZeroboxController < ApplicationController
  def index

  end
  
  def calendar
  	  if !params[:size]
  	  	  #not ok
  	  end
	  all = params[:all]
	  @size = params[:size]

  	  if params[:promoter_hash]
  	  	  promoter_hash = params[:promoter_hash]
  	  	  refresh_url = "/zerobox/calendar?promoter_hash=" + params[:promoter_hash] + "&size=" + params[:size]

		  result = Achievement.where(:gravatar_hash=>promoter_hash)
		  if result
			email = result[0].email
			@flyers = Event.where(:email=>email).where('validated > 0').order('expiry') if all
			@flyers = Event.where(:email=>email).where('validated > 0').where(['expiry > ?', Time.now().beginning_of_day - 1.day]).order('expiry') if !all
		  end
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

  def box
  	  if !params[:size]
  	  	  #not ok
  	  end
	  all = params[:all]
	  @size = params[:size]

	  # A promoter slideshow
	  @flyers = Event.valid_by_promoter(params[:promoter_hash]) if params[:promoter_hash] and all
	  @flyers = Event.current_and_valid_by_promoter(params[:promoter_hash]) if params[:promoter_hash] and !all

	  # A point-radius slideshow
	  @flyers = Event.current_and_valid_by_ll_and_radius(params[:ll], params[:radius]) if params[:ll]

	  # A venue oriented slideshow
	  @flyers = Event.current_and_valid_by_venue(params[:venue_id]) if params[:venue_id]

	  respond_to do |format|
	  	  format.html { render :template=>"zerobox/slideshow", :locals=>{:refresh_url=>refresh_url}}
	  	  format.json { render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info]) }
	  end
  end
