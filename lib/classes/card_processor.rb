class CardProcessor
  include Payment

  def initialize acct
    @acct = acct
  end

  # delete saved cards
  def remove_cards usr
    usr.card_accounts.delete_all if usr.has_card_account?
  end

  # create card
  def save_card
    Rails.logger.info "PXB Save card: #{@acct.token} " 
    Rails.logger.info "PXB Save card: #{@acct.cust_token} " 
    if CardAccount.find_by(user_id: @acct.user_id, 
      card_no: @acct.card_number[@acct.card_number.length-4..@acct.card_number.length], zip: @acct.zip, 
      expiration_month: @acct.expiration_month, expiration_year: @acct.expiration_year)
      @acct.errors.add :base, "Card already exists. Please re-enter card."
      return false
    end
    card = Payment::create_card @acct

    # check for errors
    unless card.blank? 
      return false if @acct.errors.any?

      Rails.logger.info "PXB Save Account: #{@acct.token} number: #{card.id}" 
      result = Payment::assign_card card, @acct, @acct.token
    else
      @acct.errors.add :base, "Card info is invalid. Please re-enter."
      return false
    end

    # save new account
    @acct.save!
  end

  # add card
  def add_card model, token
    remove_cards(model.user)  # remove old cards to make this card the default

    # get last 4 of card
    card_num = model.card_number[model.card_number.length-4..model.card_number.length] rescue nil

    # check if card exists
    unless card = model.user.card_accounts.where("card_no = ?", card_num).first
      card = model.user.card_accounts.build card_no: card_num, expiration_month: model.expiration_month,
	         expiration_year: model.expiration_year, card_code: model.card_code, zip: model.zip, card_type: model.card_type 
      result = check_token card, token, model
    end
    card.errors.any? || !result ? false : card 
  end
  
  # check if token was already created
  def check_token card, token, model
    if token && model.user.acct_token
      Payment::assign_card card, model, token
      card.token = token
      result = card.save
    else
      result = card.save_account 
    end
  end

  # delete card from svc provider
  def delete_card
    result = reset_card # Payment::delete_card @acct.token, @acct if @acct.token

    # remove card
    unless result 
      @acct.errors.add :base, "Error: There was a problem with your account."
      false
    end
    result
  end

  def reset_card
    result = @acct.update_attributes(status: 'removed', default_flg: nil) 
    if card = CardAccount.where(user_id: @acct.user_id, status: 'active').first
      card.update_attribute(:default_flg, 'Y')
    end
    return result
  end

  # return list of card holders or list of cards for a given user based on params
  def card_list usr, aFlg
    if usr.is_admin? && aFlg  
      User.joins(:card_accounts).include_list.where('card_accounts.status = ?', 'active').uniq.reorder('first_name ASC')  
    else
      CardAccount.inc_list.where(user_id: usr, status: 'active')
    end
  end

  def toggle_default_flg
    if @acct.default_flg == 'Y'
      @acct.user.card_accounts.where("default_flg = 'Y' AND id != ?", @acct.id).update_all(default_flg: nil)
    end
  end
end
