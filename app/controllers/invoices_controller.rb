  require 'will_paginate/array' 
class InvoicesController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!
  skip_load_resource only: [:index]
  skip_authorize_resource :only => [:autocomplete_user_first_name]
  before_filter :load_data, only: [:index, :sent, :received, :new, :show, :edit]
  before_filter :load_invoice, only: [:show, :edit, :update, :destroy, :remove, :decline]
  before_filter :mark_message, only: [:new, :show, :edit]
  before_filter :set_params, only: [:create, :update]
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name
  respond_to :html, :js, :json, :mobile
  layout :page_layout
  include ControllerManager

  def new
    @invoice = Invoice.load_new(@user, params[:buyer_id], params[:pixi_id])
    redirect_to sent_invoices_path, notice: NO_INV_PIXI_MSG unless @invoice
  end
   
  def index
    respond_with(@invoices = Invoice.includes(:buyer, :seller).paginate(page: @page, per_page: 15))
  end
   
  def sent
    respond_with(@invoices = Invoice.get_invoices(@user).paginate(page: @page, per_page: 15))
  end
   
  def received
    respond_with(@invoices = Invoice.get_buyer_invoices(@user).paginate(page: @page, per_page: 15))
  end

  def show
    respond_with(@invoice) do |format|
      format.json { render json: {invoice: @invoice, user: @user} }
    end
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
    pixi_id = @invoice.listings.first.pixi_id if params[:status] == 'cancel'
    if @invoice.destroy
      @invoices = Invoice.get_invoices(@user).paginate(page: @page, per_page: 15)
      respond_with(@invoice)
    else
      respond_with(@invoice)
    end  
  end

  def remove
    if @invoice.update_attribute(:status, 'removed')
      redirect_to sent_invoices_path, notice: 'Invoice was removed successfully.'
    else
      render action: :show, error: "Invoice was not removed. Please try again."
    end
  end

  def decline
    respond_with(@invoice) do |format|
      if @invoice.decline params[:reason]
        format.json { render json: {invoice: @invoice} }
        if params[:reason] == 'Did Not Want (Buy Now)'
          format.html { redirect_to listing_path(@invoice.listings.first.pixi_id) }
        else
          format.html { redirect_to received_invoices_path, notice: 'Invoice was declined successfully.' }
        end
      else
        format.html { render action: :show, error: "Invoice was not declined. Please try again." }
        format.json { render json: { errors: @invoice.errors.full_messages }, status: 422 }
      end
    end
  end

  protected

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page = params[:page] || 1
  end

  def load_invoice
    @invoice = Invoice.inc_list.find params[:id]
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    super(parameters).active rescue nil
  end

  def set_params
    params[:invoice] = JSON.parse(params[:invoice]) if request.xhr?
  end

  def mark_message
    ControllerManager::mark_message params[:cid], @user if params[:cid]
  end
end
