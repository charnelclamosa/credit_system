# frozen_string_literal: true
require_dependency 'application_controller'
module KarotaCredits
	class CreditsController < ActionController::API
	
		def index
			@donuts = { name: "donut", description: "delicious!" }
			render json: @donuts
		end
		
		def show
		end
	end
end