class ToolsController < ApplicationController
	def opengraph
		render :json=>OpenGraph.fetch(params[:url]).to_json
	end
end
