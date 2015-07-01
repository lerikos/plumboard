class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager, Payment

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller

    # send post
    send_post model
  end

  def after_update model
    send_post(model) if model.unpaid?
    
    # toggle status
    if model.paid?
      mark_pixi(model) 

      # credit seller account
      Payment::credit_seller_account model if model.amount > 0
    end

    if model.declined?
      # send message in PixiChat
      Post.add_post(model, model.listings.first, model.buyer, model.seller, model.decline_msg, 'inv')

      # send email
      UserMailer.delay.send_decline_notice(model, model.decline_msg)

      # delete wants if buyer selected "Did Not Want"
      if model.decline_reason == "Did Not Want"
        model.listings.each do |listing|
          want = model.buyer.pixi_wants.find_by_pixi_id(listing.pixi_id)
          want.destroy if want
        end
      end
    end
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listings.first if model.listings
    UserMailer.delay.send_invoice_notice(model)
  end

  # mark pixi as sold
  def mark_pixi model
    model.listings.find_each do |listing|
      listing.mark_as_sold 

      # mark want as sold
      PixiWant.set_status(listing.pixi_id, model.buyer_id, 'sold')
    end
  end
end
