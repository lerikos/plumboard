module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # devise settings
  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

  # set blank user photo based on gender
  def showphoto(gender)       
    @photo = gender == "Male" ? "headshot_male.jpg" : "headshot_female.jpg"
  end

  # used to toggle breadcrumb images based on current registration step
  def bc_image(bcrumb, val, file1, file2)
    bcrumb >= val ? file1 : file2     
  end

  # used do determine if search form is displayed
  def display_search
    case controller_name
      when 'listings'; render 'shared/search' if action_name != 'show'
      when 'posts'; render 'shared/search_posts'
      when 'users'; render 'shared/search_users'
      when 'pending_listings'; render 'shared/search_pending'
    end
  end

  # truncate timestamp in words
  def ts_in_words tm
    time_ago_in_words(tm).gsub('about','') + ' ago' if tm
  end

  # get number of unread messages for user
  def get_unread_count(usr)
    Post.unread_count usr
  end

  # set pixi logo home path
  def pixi_home
    cls = mobile_device? ? 'px-logo' : controller_name == 'transactions' ? 'ppay-logo' : 'pixi-logo'
    if mobile_device?
      logo = controller_name == 'transactions' ? 'sm_pixipay.png' : 'sm_px_word_logo.png'
    else
      logo = controller_name == 'transactions' ? 'rsz_pixipay.png' : 'px_word_logo.png'
    end
    link_to image_tag(logo, class: cls), root_path
  end

  # set home path
  def get_home_path
    signed_in? ? categories_path : root_path 
  end

  # set image
  def get_image model, file_name
    if model
      !model.any_pix? ? file_name : model.pictures[0].photo.url
    else
      file_name
    end
  end

  # return sites based on pixi type
  def get_sites ptype
    ptype ? Site.with_new_pixis : Site.active_with_pixis
  end

  # set display date 
  def get_local_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y') if tm
  end

  # set display time 
  def get_local_time(tm)
    tm.strftime("%l:%M %p") unless tm.blank?
  end

  # parse navbar menu
  def parse_item val, item
    (val.is_a? String) ? val : val[item.to_sym]
  end

  # set appropriate submenu nav bar
  def set_submenu *args
    case parse_item(args[0], 'name')
      when 'Invoices'; render partial: 'shared/navbar_invoices', locals: { active: parse_item(args[0], 'action') || 'sent' }
      when 'Categories'; render 'shared/navbar_categories'
      when 'Pixis'; render 'shared/navbar_pixis'
      when 'Pixi'; render 'shared/navbar_show_pixi'
      when 'My Pixis'; render 'shared/navbar_mypixis'
      when 'My Accounts'; render 'shared/navbar_accounts'
      when 'Pending Orders'; render 'shared/navbar_pending'
      when 'Messages'; render 'shared/navbar_posts'
      when 'Home'; render 'shared/navbar_home'
      when 'PixiPosts'; render 'shared/navbar_pixi_post'
      when 'Inquiries'; render 'shared/navbar_inquiry'
      else render 'shared/navbar_main'
    end
  end
  
  # build array for quantity selection dropdown
  def get_ary
    (1..99).inject([]){|x,y| x << y}
  end

  # set numeric display
  def num_display model, fld
    number_with_precision(model.send(fld), :precision=>2)
  end

  # set account path based on user has an account
  def get_account_path
    if @user.has_bank_account? 
      @account ||= @user.bank_accounts.first
      bank_account_path(@account)
    else 
      new_bank_account_path
    end
  end

  # use bootstrap for flash messages
  def bootstrap_class_for flash_type
     case flash_type
       when :success
         "alert-success"
       when :error
         "alert-error"
       when :alert
         "alert-block"
       when :notice
         "alert-info"
       else
         flash_type.to_s
     end
  end

  # set path based on invoice count
  def get_unpaid_path
    if @user.unpaid_invoice_count > 1 
      @invoice = @user.unpaid_received_invoices.first
      invoice_path(@invoice)
    end
  end

  # toggle header if str matches
  def toggle_header? title
    str = 'Pixi|Invoice|Account|Post|Setting|Order|Purchase'  # set match string
    !(title.downcase =~ /^.*\b(#{str.downcase})(s){0,1}\b.*$/i).nil?
  end

  # convert to currency
  def ntc val
    number_to_currency val
  end
end
