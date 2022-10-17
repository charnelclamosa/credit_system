# frozen_string_literal: true

KarotaCredits::Engine.routes.draw do
	get '/' => 'credits#index'
	get '.json' => 'credits#index'
end