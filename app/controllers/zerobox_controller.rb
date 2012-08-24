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

	  if params[:hash]
			  
	  	  box = Box.find_by_idhash(params[:hash])
	  	  if !box
	  	  	  box = Box.new()
	  	  	  box.name = "New Box"
	  	  	  box.idhash = params[:hash]
	  	  	  #box.config = {:venue_id => '4b6f5e6ef964a5207aed2ce3'}.to_json
	  	  	  box.config = {:ll => "38.0303546973,-78.4798640013", :radius => 5}.to_json
	  	  end
	  	  box.lasthit = Time.now()
	  	  box.save
	  	  
	  	  config_hash = ActiveSupport::JSON.decode(box.config)
	  	  
		  # A promoter slideshow
		  @flyers = Event.by_promoter(config_hash["promoter_hash"]).is_valid if config_hash["promoter_hash"] and all
		  @flyers = Event.by_promoter(config_hash["promoter_hash"]).is_valid.is_current if config_hash["promoter_hash"] and !all
	
		  # A point-radius slideshow
		  @flyers = Event.by_ll_and_radius(config_hash["ll"], config_hash["radius"]).is_valid.is_current if config_hash["radius"]
	
		  # A venue oriented slideshow
		  @flyers = Event.by_venue(config_hash["venue_id"]).is_valid.is_current if config_hash["venue_id"]
		  
	  end

	  respond_to do |format|
		  format.html { render :template=>"zerobox/slideshow"}
	  	  format.json { render :json=>@flyers.to_json(:only => [:id,:lat,:lng,:expiry, :media, :fbevent, :venue_id], :methods => [:map_photo, :map_photo_info, :gravatar, :promoter]) }
	  end
  end
  
  def list
  	  @boxes = Box.all
  	  
  	  respond_to do |format|
	  	  format.html { render :template=>"zerobox/list"}
	  	  format.json { render :json=>@boxes.to_json }
	  end
  end
  
  def edit
  	  @box = Box.find(params[:id])
  end
  
  def update
  	  @box = Box.find(params[:id])
  	  if @box.update_attributes(params[:box])
  	  	  head :ok
  	  end
  end
  
end
