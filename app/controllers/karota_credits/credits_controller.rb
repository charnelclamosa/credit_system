# frozen_string_literal: true
module KarotaCredits

  CREDIT_BALANCE_COL = 'credit_balance'
  MAX_CREDIT_BALANCE = 100

  class CreditsController < ActionController::API
    # This API class is responsible for adding and gifting credits
    # to the users of the platform.
    before_action :authenticate_api_key

    def index
      head 200
    end

    # Authenticate the 'Api-Key' in the HTTP header
    def authenticate_api_key
      raise Discourse::InvalidAccess unless request.headers["Api-Key"]
      @hashed_api_key = ApiKey.hash_key(request.headers["Api-Key"])
      api_key_record = ApiKey.find_by(key_hash: @hashed_api_key)
      raise Discourse::InvalidAccess unless api_key_record
    end

    # Returns the mean of the credit balance of all users.
    def get_credits_mean
      credits_mean = UserCustomField.where(name: CREDIT_BALANCE_COL).average("value::float")
      render json: credits_mean
		end

    # Adds credit to the credit balance of all users.
    # This method is expecting an API parameter 'amount'.
    def add_credits
      params.require(:amount)
      amount = params[:amount]

      credits = UserCustomField.where(name: CREDIT_BALANCE_COL)
      credits.each do |credit|
        new_credit = calculate_new_credit_balance(credit[:value], amount)
        update_credit_balance(credit[:user_id], new_credit)
      end
    end

    # Calculate the new credit balance.
    # Params:
    # +credit+:: Current credit balance of the user.
    # +amount+:: Amount that will be added to the credit balance of the user.
    def calculate_new_credit_balance(credit, amount)
      credit = credit.to_f
      amount = amount.to_f
      user_polarity = get_user_polarity
      new_credit = amount * (1 - user_polarity) + credit
      new_credit
    end

    # Return the user polarity, temporarily returns 0.
    def get_user_polarity
      0
    end

    # Updates the credit balance of users.
    def update_credit_balance(user_id, new_credit)
      UserCustomField
        .where(name: CREDIT_BALANCE_COL, user_id: user_id)
        .update_all(value: new_credit, updated_at: DateTime.now)
    end
    
    # Get the user ids of users that has credit balance.
    def get_user_ids_with_credits
      UserCustomField.select(:user_id).where(name: CREDIT_BALANCE_COL)
    end

    ##
    # Gift users with credit balance based on behavior
    # Algoritm
    # - Find users with credit balance
    # - Compute the gained rewards of each user
    # - Add the gained rewards to the credit balance of each user
    # API parameters:
    # +amount+:: Amount that will be used in the formula for calculating the reward. Required.
    # +date+:: Date that will be used for looking up the user's activity.
    def gift_rewards
      params.require(:amount)

      amount = params[:amount].to_f
      date = params[:date] ||= (DateTime.now - 1.day).strftime('%Y-%m-%d')

      ucf_credit_records = get_user_ids_with_credits
      ucf_credit_records.each do |record|
        reward = get_rewards(amount, record[:user_id], date)
        new_credit_balance = add_rewards_to_credits(record[:user_id], reward)
        update_credit_balance(record[:user_id], new_credit_balance)
      end
    end

    # Calculate the gained reward of a user based on the user's behavior
    # and activity.
    # Returns
    # +gained_reward+:: Credit amount the user will get.
    def get_rewards(amount, user_id, date)
      @post_polarization_score = get_post_polarization_score(user_id)
      @total_created_posts = get_total_posts(user_id, date)
      @total_followers = get_new_followers(user_id)
      @total_likes_received = get_new_likes_received(user_id, date)
      gained_reward = (0.5 + amount) * (1 - @post_polarization_score) * @total_created_posts * (@total_followers + @total_likes_received)
      gained_reward
    end

    # Get the polarity of the post content. 
    # Currently, we are using the `like_score` column
    # of the `posts` table to determine the polarity of the post.
    # Params:
    # +user_id+:: User id of the post creator.
    def get_post_polarization_score(user_id)
      sql = <<~SQL
        SELECT AVG(ABS(like_score)) mean_score from posts
        WHERE user_id = :user_id
      SQL
      scores = DB.query(sql, user_id: user_id)
      return 0 if scores[0].mean_score.nil?
      scores[0].mean_score
    end

    # Get the total created post of a user on a specific date.
    def get_total_posts(user_id, date)
      sql = <<~SQL
        SELECT COUNT(*) total_posts from posts
        WHERE created_at::DATE = :created_at
        AND user_id = :user_id
      SQL
      total_posts_created = DB.query(sql, created_at: date, user_id: user_id)
      total_posts_created[0].total_posts
    end

    # Returns the new followers of the user.
    # Will temporarily returns 0 because follow is not
    # supported by default in Discourse.
    def get_new_followers(user_id)
      return 0
    end

    # Get the total received likes of post(s) of a post creator
    # on a specific date.
    def get_new_likes_received(user_id, date)
      sql = <<~SQL
        SELECT SUM(like_count) total_likes from posts
        WHERE created_at::DATE = :created_at
        AND user_id = :user_id
      SQL
      total_likes = DB.query(sql, created_at: date, user_id: user_id)
      return 0 if total_likes[0].total_likes.nil?
      total_likes[0].total_likes
    end

    # Calculate the new credit balance of the user based on
    # gained rewards.
    def add_rewards_to_credits(user_id, gained_reward)
      result = UserCustomField.select(:value)
        .where(name: CREDIT_BALANCE_COL, user_id: user_id)
        .first
      current_credit_balance = result.value.to_f
      new_credit_balance = current_credit_balance + gained_reward
      new_credit_balance = [
          (new_credit_balance - 1 + (1 - @post_polarization_score) * gained_reward / 2 + 1), 
          MAX_CREDIT_BALANCE
        ].min
      new_credit_balance
    end
  end
end