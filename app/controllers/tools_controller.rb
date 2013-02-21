class ToolsController < ApplicationController
	def opengraph
		render :json=>OpenGraph.fetch(params[:url]).to_json
	end

	def reverse_venue
		result = {}
		if params[:venue_id]
			venue = Venue.reverse_venue_lookup( params[:venue_id] )
			puts 'Venue Info: ' + venue.to_s
			result[:venue_name] = venue["name"]
			result[:venue_location] = venue["location"].has_key?("address") ? venue["location"]["address"] : ""
			result[:venue_icon] = proc do
						      			if venue["categories"].length > 0
							    			icon_info = venue["categories"][0]["icon"]
							    			icon = icon_info["prefix"] + icon_info["sizes"][2].to_s + icon_info["name"]
						      			else
							    			icon = nil
						      			end
					      			end.call
		end
		render :json=>result.to_json
	end
end
