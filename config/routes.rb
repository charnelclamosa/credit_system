# frozen_string_literal: true

KarotaCredits::Engine.routes.draw do
  # Legend:
  # GET '/' => Returns the mean of credit balance of all users
  # PUT '/' => Adds credit amount to the existing credit balance of users.
  # PUT '/rewards' => Add credits to users that has credit balance as
  #   a reward for good behavior.
  get '/' => 'credits#get_credits_mean'
  put '/' => 'credits#add_credits'
	put '/rewards' => 'credits#gift_rewards'
end