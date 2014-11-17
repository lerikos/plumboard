require 'will_paginate/array' 
class TempListingsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_permissions, only: [:create, :show, :edit, :update, :delete]
  before_filter :load_data, only: [:index, :unposted]
  before_filter :set_params, only: [:create, :update]
  autocomplete :site, :name, :full => true, :limit => 20
  autocomplete :user, :first_name, :extra_data => [:first_name, :last_name], :display_value => :pic_with_name, if: :has_pixan?
  include ResetDate
  respond_to :html, :json, :js, :mobile
  layout :page_layout

  def index
    respond_with(@listings = TempListing.check_category_and_location(@status, @cat, @loc, @page).paginate(page: @page, per_page: 15))
  end

  def new
    @listing = TempListing.new pixan_id: params[:pixan_id]
    @photo = @listing.pictures.build
    respond_with(@listing)
  end

  def show
    respond_with(@listing = TempListing.find_by_pixi_id(params[:id]))
  end

  def edit
    @listing = TempListing.find_by_pixi_id(params[:id]) || Listing.find_by_pixi_id(params[:id]).dup_pixi(false)
    @photo = @listing.pictures.build if @listing
    respond_with(@listing)
  end

  def update
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.update_attributes(params[:temp_listing])
        format.json { render json: {listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def create
    @listing = TempListing.new params[:temp_listing]
    respond_with(@listing) do |format|
      if @listing.save
        flash[:notice] = 'Your pixi has been saved as a draft'
        format.json { render json: {listing: @listing} }
      else
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def submit
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.resubmit_order
        format.json { render json: {listing: @listing} }
      else
        format.html { redirect_to @listing, alert: "Pixi was not submitted. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def destroy
    @listing = TempListing.find_by_pixi_id params[:id]
    respond_with(@listing) do |format|
      if @listing.destroy  
        format.html { redirect_to get_root_path }
        format.mobile { redirect_to get_root_path }
	format.json { head :ok }
      else
        format.html { render action: :show, error: "Pixi was not removed. Please try again." }
        format.mobile { render action: :show, error: "Pixi was not removed. Please try again." }
        format.json { render json: { errors: @listing.errors.full_messages }, status: 422 }
      end
    end
  end

  def unposted
    respond_with(@listings = TempListing.draft.get_by_seller(@user).paginate(page: @page))
  end

  def pending
    respond_with(@listings = TempListing.get_by_status('pending').get_by_seller(@user).paginate(page: @page))
  end
  
  protected

  def page_layout
    mobile_device? ? 'form' : 'application'
  end

  def load_data
    @page, @cat, @loc, @loc_name = params[:page] || 1, params[:cid], params[:loc], params[:loc_name]
    @status = NameParse::transliterate params[:status] if params[:status]
    @loc_name ||= LocationManager::get_loc_name(request.remote_ip, @loc || @region, @user.home_zip)
    @loc ||= LocationManager::get_loc_id(@loc_name, @user.home_zip)
  end

  # parse fields to adjust formatting
  def set_params
    if params[:file]
      @pic = @listing.pictures.build
      @pic.photo = File.new params[:file].tempfile 
    end
    respond_to do |format|
      format.html { params[:temp_listing] = ResetDate::reset_dates(params[:temp_listing]) }
      format.json { params[:temp_listing] = JSON.parse(params[:temp_listing]) }
    end
  end

  # parse results for active items only
  def get_autocomplete_items(parameters)
    items = super(parameters)
    items = items.active(false) rescue items
  end

  # check if pixipost to enable buyer autocomplete
  def has_pixan?
    !params[:pixan_id].blank?
  end

  def check_permissions
    authorize! :crud, TempListing
  end
end
