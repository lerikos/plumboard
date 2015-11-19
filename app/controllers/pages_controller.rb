class PagesController < ApplicationController
  respond_to :html, :json, :js, :mobile
  before_filter :load_data, only: [:home]
  layout :page_layout
  include LocationManager
  
  def help
    @faqs = Faq.active
  end

  def home
    @listings = Listing.active.board_fields.paginate(page: @page, per_page: @per_page) 
  end

  def about
  end

  def privacy
  end

  def terms
  end

  def howitworks
  end

  def giveaway
  end

  def location_name
    site = LocationManager::get_region params[:loc_name]
    @region, @loc_name = [site.id, site.name]
    respond_with(site)
  end

  protected

  def page_layout
    action_name == 'home' ? 'pages' : 'about'
  end

  def load_data
    @page, @per_page = params[:page] || 1, params[:per_page] || PIXI_DISPLAY_AMT
  end
end
