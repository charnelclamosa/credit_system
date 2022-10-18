# frozen_string_literal: true

KarotaCredits::Engine.routes.draw do
	get '/' => 'credits#get_credits_mean'
	put '/' => 'credits#add_credits'
end