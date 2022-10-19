# frozen_string_literal: true
module KarotaCredits

  CREDIT_BALANCE_COL = 'credit_balance'

  class CreditsController < ActionController::API
    before_action :authenticate_api_key

    def index
      head 200
    end

    ##
    # Authenticate the 'Api-Key' in the HTTP header
    def authenticate_api_key
      raise Discourse::InvalidAccess unless request.headers["Api-Key"]
      @hashed_api_key = ApiKey.hash_key(request.headers["Api-Key"])
      api_key_record = ApiKey.find_by(key_hash: @hashed_api_key)
      raise Discourse::InvalidAccess unless api_key_record
    end

    ##
    # Returns the mean of the credit balance of all users.
    def get_credits_mean
      credits_mean = UserCustomField
        .where(name: CREDIT_BALANCE_COL)
        .average("value::float")
      render json: credits_mean
		end

    ##
    # Adds credit to the credit balance of all users.
    # This method is expecting an API parameter 'amount'.
    def add_credits
      params.require(:amount)

      credits = UserCustomField.where(name: CREDIT_BALANCE_COL)
      credits.each do |credit|
        # The updating of credits will happen in this iteration
        new_credit = calculate_new_credit_balance(credit[:value], params[:amount])
        update_credit_balance(credit[:id], new_credit)
      end
    end

    ##
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

    def update_credit_balance(id, new_credit)
      UserCustomField
        .where(id: id)
        .update_all(value: new_credit, updated_at: DateTime.now)
   end
  end
end