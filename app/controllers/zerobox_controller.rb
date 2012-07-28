class ZeroboxController < ApplicationController
  def index

  end

  def calendar
  	  if !params[:size]
  	  	  #not ok
  	  end
	  @size = params[:size]

	  # promoter
	  @flyers = Event.by_promoter(params[:promoter_hash]).is_valid.in_range(params[:start], params["end"]) if params[:promoter_hash]

	  # venue
	  @flyers = Event.by_venue(params[:venue_id]).is_valid.in_range(params[:start], params["end"]) if params[:venue_id]

	  # point-radius
	  @flyers = Event.by_ll_and_radius(params[:ll], params[:radius]).is_valid.in_range(params[:start], params["end"]) if params[:ll]

	  respond_to do |format|
	  	  format.html { render :template=>"zerobox/calendar"}
	  	  format.json { render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :gravatar, :promoter]) }
	  end
  end

  def box
  	  if !params[:size]
  	  	  #not ok
  	  end
	  all = params[:all]
	  @size = params[:size]

	  # A promoter slideshow
	  @flyers = Event.by_promoter(params[:promoter_hash]).is_valid if params[:promoter_hash] and all
	  @flyers = Event.by_promoter(params[:promoter_hash]).is_valid.is_current if params[:promoter_hash] and !all

	  # A point-radius slideshow
	  @flyers = Event.by_ll_and_radius(params[:ll], params[:radius]).is_valid.is_current if params[:ll]

	  # A venue oriented slideshow
	  @flyers = Event.by_venue(params[:venue_id]).is_valid.is_current if params[:venue_id]

	  respond_to do |format|
		  format.html { render :template=>"zerobox/slideshow"}
	  	  format.json { render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :gravatar, :promoter]) }
	  end
  end
end
