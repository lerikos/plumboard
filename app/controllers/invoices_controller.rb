require 'will_paginate/array' 
class InvoicesController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  skip_authorize_resource :only => [:autocomplete_user_first_name]
  before_filter :load_data, only: [:index, :sent, :received]
  before_filter :load_invoice, only: [:show, :edit, :update, :destroy, :remove]
  before_filter :set_params, only: [:create, :update]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def new
    respond_with(@invoice = Invoice.load_new(@user, params[:buyer_id], params[:pixi_id]))
  end
   
  def index
    respond_with(@invoices = Invoice.all.paginate(page: @page))
  end
   
  def sent
    respond_with(@invoices = Invoice.get_invoices(@user).paginate(page: @page))
  end
   
  def received
    respond_with(@invoices = Invoice.get_buyer_invoices(@user).paginate(page: @page))
  end

  def show
    respond_with(@invoice)
  end

  def edit
    respond_with(@invoice)
  end

  def update
    respond_with(@invoice) do |format|
      if @invoice.update_attributes(params[:invoice])
        format.json { render json: {invoice: @invoice} }
      else
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @invoice = @user.invoices.build params[:invoice]
    respond_with(@invoice) do |format|
      if @invoice.save
        format.json { render json: {invoice: @invoice} }
      else
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    if @invoice.destroy
      @invoices = Invoice.get_invoices(@user).paginate(page: @page)
    end  
    respond_with(@invoice)
  end

  def remove
    if @invoice.update_attribute(:status, 'removed')
      redirect_to sent_invoices_path, notice: 'Invoice was removed successfully.'
    else
      render action: :show, error: "Invoice was not removed. Please try again."
    end
  end

  private

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end

  def load_invoice
    @invoice = Invoice.find params[:id]
  end

  def set_params
    params[:invoice] = JSON.parse(params[:invoice]) if request.xhr?
  end
end
