class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager, CalcTotal

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller

    # send post
    send_post model
  end

  def after_update model
    # send post
    send_post(model) if model.unpaid?

    # toggle status
    if model.paid?
      mark_pixi(model) 

      # credit seller account
      if model.amount > 0

        # get txn amount & fee
        fee = CalcTotal::get_convenience_fee model.amount

        # process payment
        result = model.bank_account.credit_account(model.amount - fee)

        # record payment
	if result
	  PixiPayment.add_transaction model, fee, result.uri, result.id 

          # send receipt upon approval
          # UserMailer.delay.send_payment_receipt(model, result)
          UserMailer.send_payment_receipt(model, result).deliver
	end
      end
    end
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listing  
  end

  # mark pixi as sold
  def mark_pixi model
    model.listing.mark_as_sold 
  end
end
