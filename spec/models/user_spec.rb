require 'spec_helper'

describe User do
  before(:all) do
    @user = create(:contact_user, status: 'active')
  end

  subject { @user }

  describe "user methods", base: true do
    it_behaves_like "an user"
    it { is_expected.to respond_to(:password) }
    it { is_expected.to respond_to(:password_confirmation) }
    it { is_expected.to respond_to(:birth_date) }
    it { is_expected.to respond_to(:remember_me) }
    it { is_expected.to respond_to(:gender) }
    it { is_expected.to respond_to(:provider) }
    it { is_expected.to respond_to(:uid) }
    it { is_expected.to respond_to(:fb_user) }
    it { is_expected.to respond_to(:pictures) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:acct_token) }
    it { is_expected.to respond_to(:cust_token) }
    it { is_expected.to respond_to(:user_type_code) }
    it { is_expected.to respond_to(:business_name) }
    it { is_expected.to respond_to(:ref_id) }
    it { is_expected.to respond_to(:url) }
    it { is_expected.to respond_to(:ein) }
    it { is_expected.to respond_to(:ssn_last4) }

    it { is_expected.to respond_to(:interests) }
    it { is_expected.to respond_to(:contacts) }
    it { is_expected.to respond_to(:user_interests) }
    it { is_expected.to respond_to(:transactions) }
    it { is_expected.to respond_to(:user_pixi_points) }
    it { is_expected.to respond_to(:listings) } 
    it { is_expected.to respond_to(:temp_listings) } 
    it { is_expected.to respond_to(:active_listings) } 
    it { is_expected.to respond_to(:pixi_posted_listings) } 
    it { is_expected.to respond_to(:posts) } 
    it { is_expected.to respond_to(:incoming_posts) } 
    it { is_expected.to respond_to(:invoices) } 
    it { is_expected.to respond_to(:received_invoices) } 
    it { is_expected.to respond_to(:unpaid_received_invoices) } 
    it { is_expected.to respond_to(:unpaid_invoices) } 
    it { is_expected.to respond_to(:paid_invoices) } 
    it { is_expected.to respond_to(:bank_accounts) } 
    it { is_expected.to respond_to(:card_accounts) } 
    it { is_expected.to respond_to(:comments) }
    it { is_expected.to respond_to(:ratings) }
    it { is_expected.to respond_to(:inquiries) }
    it { is_expected.to respond_to(:seller_ratings) }
    it { is_expected.to respond_to(:pixi_posts) }
    it { is_expected.to respond_to(:active_pixi_posts) }
    it { is_expected.to respond_to(:pixan_pixi_posts) }

    it { is_expected.to have_many(:received_conversations).class_name('Conversation').with_foreign_key('recipient_id') }
    it { is_expected.to have_many(:sent_conversations).class_name('Conversation').with_foreign_key('user_id') }
    it { is_expected.to have_many(:active_listings).class_name('Listing').with_foreign_key('seller_id')
      .conditions("status='active' AND end_date >= curdate()") }
    it { is_expected.to have_many(:pixi_posted_listings).class_name('Listing').with_foreign_key('seller_id')
      .conditions("status='active' AND end_date >= curdate() AND pixan_id IS NOT NULL") }
    it { is_expected.to have_many(:purchased_listings).class_name('Listing').with_foreign_key('buyer_id').conditions(:status=>"sold") }
    it { is_expected.to respond_to(:pixan_pixi_posts) }
    it { is_expected.to have_many(:pixan_pixi_posts).class_name('PixiPost').with_foreign_key('pixan_id') }
    it { is_expected.to respond_to(:pixi_likes) }
    it { is_expected.to have_many(:pixi_likes) }
    it { is_expected.to respond_to(:saved_listings) }
    it { is_expected.to have_many(:saved_listings) }
    it { is_expected.to respond_to(:pixi_wants) }
    it { is_expected.to have_many(:pixi_wants) }
    it { is_expected.to respond_to(:pixi_asks) }
    it { is_expected.to have_many(:pixi_asks) }
    it { is_expected.to respond_to(:preferences) }
    it { is_expected.to have_many(:ship_addresses) }
    it { is_expected.to have_many(:preferences).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:preferences).allow_destroy(true) }
    it { is_expected.to belong_to(:user_type).with_foreign_key('user_type_code') }
    it { is_expected.to have_many(:active_bank_accounts).class_name('BankAccount').conditions(:status=>"active") }
    it { is_expected.to have_many(:active_card_accounts).class_name('CardAccount').conditions(:status=>"active") }

    it { is_expected.to respond_to(:unpaid_invoice_count) } 
    it { is_expected.to respond_to(:has_unpaid_invoices?) } 
    it { is_expected.to respond_to(:has_address?) } 
    it { is_expected.to respond_to(:has_prefs?) } 
    it { is_expected.to respond_to(:has_pixis?) } 
    it { is_expected.to respond_to(:has_bank_account?) } 
    it { is_expected.to respond_to(:has_card_account?) } 

    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:birth_date) }
#    it { should validate_presence_of(:url).on(:create) }
#    it { should validate_uniqueness_of(:url) }
#    it { should validate_length_of(:url).is_at_least(2) }
#    it { should allow_value('Tom').for(:url) }
#    it { should_not allow_value("a").for(:url) }
  it { is_expected.to allow_value(457211111).for(:ein) }
  it { is_expected.not_to allow_value(725).for(:ein) }
  it { is_expected.not_to allow_value('a725').for(:ein) }
  it { is_expected.to allow_value(4572).for(:ssn_last4) }
  it { is_expected.not_to allow_value(725).for(:ssn_last4) }
  it { is_expected.not_to allow_value('a725').for(:ssn_last4) }

    it { is_expected.to have_many(:favorite_sellers) }
    it { is_expected.to have_many(:sellers).conditions("favorite_sellers.status"=>"active") }
    it { is_expected.to have_many(:inverse_favorite_sellers).class_name('FavoriteSeller').with_foreign_key('seller_id') }
    it { is_expected.to have_many(:followers) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe 'name' do
    before :each, run: true do
      @usr = build(:user, first_name: "John", last_name: "Doe", email: "jdoe@test.com")
    end

    it "returns a user's full name as a string", run: true do
      expect(@usr.name).to eq("John Doe")
    end

    it "does not return a user's invalid full name as a string", run: true do
      expect(@usr.name).not_to eq("John Smith")
    end

    it "does not return a user's invalid full name when a business" do
      @usr = build :pixi_user, first_name: 'John', last_name: 'Smith', birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Company A'
      expect(@usr.name).not_to eq("John Smith")
    end

    it "returns a business name when a business" do
      @usr = build :pixi_user, first_name: 'John', last_name: 'Smith', birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Home + Gifts'
      expect(@usr.name).to eq("Home + Gifts")
    end

    it "returns a user's abbr name as a string", run: true do
      expect(@usr.abbr_name).to eq("John D")
      expect(@usr.abbr_name).not_to eq("John Doe")
    end
  end

  describe 'contacts' do
    before(:each) do
      @sr = @user.contacts.build attributes_for(:contact)
    end

    it "has many contacts" do 
      expect(@user.contacts).to include(@sr)
    end

    it "should destroy associated contacts" do
      @user.destroy
      [@sr].each do |s|
         expect(Contact.find_by_id(s.id)).to be_nil
       end
    end 
  end  

  describe 'temp_listings' do
    before(:each) do
      @sr = @user.temp_listings.create attributes_for(:temp_listing)
    end

    it "has many temp_listings" do 
      expect(@user.temp_listings).to include(@sr)
    end

    it "should destroy associated temp_listings" do
      @user.destroy
      [@sr].each do |s|
         expect(TempListing.find_by_id(s.id)).to be_nil
       end
    end 
  end  

  describe 'with_picture' do
    let(:user) { build :user }
    let(:pixi_user) { build :pixi_user }

    it "adds a picture" do
      expect(user.with_picture.pictures.size).to eq(1)
    end

    it "does not add a picture" do
      expect(pixi_user.with_picture.pictures.size).to eq(1)
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @user.pictures.create attributes_for(:picture)
    end

    it "has many pictures" do 
      expect(@user.pictures).to include(@sr)
    end

    it "destroys associated pictures" do
      @user.destroy
      [@sr].each do |s|
         expect(Picture.find_by_id(s.id)).to be_nil
       end
    end 
  end  

  describe 'home_zip' do
    let(:user) { build :user }
    it { expect(@user.home_zip).not_to be_nil }
    it { expect(user.home_zip).to be_nil }
    it { expect(@user.home_zip=('94108')).to eq('94108') }
    it { expect(user.home_zip=(nil)).to be_nil }
  end

  describe "must have pictures" do
    let(:user) { build :user }

    it "does not save w/o at least one picture" do
      user.user_type_code = 'BUS'
      user.business_name = 'Test Biz'
      user.save
      expect(user).not_to be_valid
    end

    it "saves with at least one picture" do
      picture = user.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      user.home_zip = '94108'
      user.save
      expect(user).to be_valid
    end

    it "saves w/o pic for individuals" do
      member = build :user
      member.home_zip = '94108'
      member.save
      member.should be_valid
    end
  end

  describe "must have zip" do
    let(:user) { build :user }
    before :each do
      picture = user.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
    end

    it "does not save w/o zip" do
      user.save
      expect(user).not_to be_valid
    end

    it "does not save with invalid zip" do
      user.home_zip = '99999'
      user.save
      expect(user).not_to be_valid
    end

    it "does not save zip with invalid length" do
      user.home_zip = '12'
      user.save
      expect(user).not_to be_valid
    end

    it "saves with zip" do
      user.home_zip = '94108'
      user.save
      expect(user).to be_valid
    end
  end

  describe 'pixis' do
    it "returns pixis" do
      @listing = create(:listing, seller_id: @user.id)
      @user.listings.create attributes_for(:listing, status: 'active')
      expect(@user.pixis).not_to be_empty
      expect(@user.has_pixis?).to be_truthy
    end

    it "does not return pixis" do
      usr = create :contact_user
      expect(usr.pixis).to be_empty
      expect(@user.has_pixis?).not_to be_truthy
    end
  end

  describe 'sold pixis' do
    it "returns pixis" do
      @listing = create(:listing, seller_id: @user.id, status: 'sold')
      expect(@user.sold_pixis).not_to be_empty
    end

    it "does not return pixis" do
      usr = create :contact_user
      expect(usr.sold_pixis).to be_empty
    end
  end

  describe 'new pixis' do
    it "returns new pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id)
      expect(@user.new_pixis).not_to be_empty
    end

    it "returns denied pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'denied')
      expect(@user.new_pixis).not_to be_empty
    end

    it "does not return new pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'pending')
      expect(@user.new_pixis).to be_empty
    end
  end

  describe 'pending pixis' do
    it "returns pending pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'pending')
      expect(@user.pending_pixis).not_to be_empty
    end

    it "does not return denied pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id, status: 'denied')
      expect(@user.pending_pixis).to be_empty
    end

    it "does not return pending pixis" do
      @temp_listing = create(:temp_listing, seller_id: @user.id)
      expect(@user.pending_pixis).to be_empty
    end
  end

  describe 'bank_account' do
    it "has account" do
      @user.bank_accounts.create attributes_for(:bank_account, status: 'active')
      expect(@user.has_bank_account?).to be_truthy
    end

    it "does not have account" do
      expect(@user.has_bank_account?).not_to be_truthy
    end
  end

  describe 'card_account' do
    it "has account" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      expect(@user.has_card_account?).to be_truthy
    end

    it "does not have account" do
      expect(@user.has_card_account?).not_to be_truthy
    end

    it "has valid card" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      expect(@user.get_valid_card).to be_truthy
    end

    it "has valid card & expired card" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active')
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year, 
        expiration_month: Date.today.month-1)
      expect(@user.get_valid_card).to be_truthy
    end

    it "has invalid card - old year" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year-1)
      expect(@user.get_valid_card).not_to be_truthy
    end

    it "has invalid card - same year, old month" do
      @user.card_accounts.create attributes_for(:card_account, status: 'active', expiration_year: Date.today.year, 
        expiration_month: Date.today.month-1)
      expect(@user.get_valid_card).not_to be_truthy
    end

    it "does not have valid card" do
      expect(@user.get_valid_card).not_to be_truthy
    end
  end

  describe 'facebook' do
    let(:user) { build :user }
    let(:auth) { OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
               provider: 'facebook', uid: "fb-12345", 
	       info: { name: "Bob Smith", image: "http://graph.facebook.com/708798320/picture?type=square" }, 
	       extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
	                email: 'bob.smith@test.com', birthday: "01/03/1989", gender: 'male' } } }) }

    it 'should return a user' do
      expect(User.find_for_facebook_oauth(auth).email).to eq('bob.smith@test.com')
    end

    it 'should return a picture' do
      expect(User.picture_from_url(user, auth)).not_to be_nil
    end
  end

  describe 'password' do
    let(:user) { build :user }

    it 'should valid password' do
      expect(user.password_required?).to be_truthy  
    end

    it 'should confirm password' do
      expect(user.confirmation_required?).to be_truthy  
    end

    it 'should not valid password' do
      user.provider = 'facebook'
      expect(user.password_required?).not_to be_truthy  
    end

    it 'should not confirm password' do
      user.provider = 'facebook'
      expect(user.confirmation_required?).not_to be_truthy  
    end
  end

  describe "pic_with_name" do 
    let(:user) { build :user }

    it "should not be true" do
      expect(user.pic_with_name).not_to be_truthy
    end

    it "should be true" do
      expect(@user.pic_with_name).to be_truthy
    end
  end

  describe "status" do 
    it { expect(@user.active?).to be_truthy }

    it 'should not be active' do
      user = build :user, status: 'inactive'
      expect(user.active?).not_to be_truthy
    end

    it 'should be inactive' do
      expect(@user.deactivate.status).not_to eq('active')
    end

    it 'should be inactive' do
      expect(@user.deactivate.status).to eq('inactive')
    end
  end

  describe 'has_address?' do
    it 'should return true' do
      expect(@user.has_address?).to be_truthy
    end

    it 'should not return true' do
      user = build :user
      expect(user.has_address?).not_to be_truthy
    end
  end

  describe 'has_prefs?' do
    it 'should return true' do
      user = create :business_user
      user.preferences.first.update_attributes(fulfillment_type_code: 'A', ship_amt: 9.99, sales_tax: 8.25)
      expect(user.reload.has_prefs?).to be_truthy
    end

    it 'should not return true' do
      user = build :user
      expect(user.has_prefs?).not_to be_truthy
    end
  end

  describe 'new_user?' do
    it 'should return true' do
      @user.sign_in_count = 1
      expect(@user.new_user?).to be_truthy
    end

    it 'should not return true' do
      user = build :user
      expect(user.new_user?).not_to be_truthy
    end
  end

  describe 'convert time' do
    it 'should return a date' do
      expect(User.convert_date("01/13/1989")).to eq("13/01/1989".to_date)
    end

    it 'should not return a date' do
      expect(User.convert_date(nil)).not_to eq("13/01/1989".to_date)
    end
  end

  describe 'birth_dt' do
    it 'should return a date' do
      expect(@user.birth_dt).to eq("04/23/1967")
    end

    it 'should not return a date' do
      @user.birth_date = nil
      expect(@user.birth_dt).not_to eq("04/23/1967")
    end
  end

  describe 'nice_date' do
    it 'returns a nice date' do
      expect(@user.nice_date(@user.created_at)).to eq(@user.created_at.utc.getlocal.strftime('%m/%d/%Y %l:%M %p'))
    end

    it 'does not return a nice date' do
      user = build :pixi_user
      expect(user.nice_date(user.created_at)).to be_nil
    end
  end

  describe 'is_pixter?', code: true do
    it { expect(@user.is_pixter?).to be_falsey }

    it 'is true' do
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      expect(@pixter.is_pixter?).to be_truthy
    end
  end

  describe 'is_member?', code: true  do
    it { expect(@user.is_member?).to be_truthy }

    it 'is false' do
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      expect(@pixter.is_member?).to be_falsey
    end
  end

  describe 'is_business?', code: true  do
    it { expect(@user.is_business?).not_to be_truthy }

    it 'is a business' do
      @company = create(:business_user) 
      expect(@company.is_business?).to be_truthy
    end
  end

  describe 'is_support?', code: true  do
    it { expect(@user.is_support?).to be_falsey }

    it 'is true' do
      @support = create(:pixi_user, user_type_code: 'SP') 
      expect(@support.is_support?).to be_truthy
    end
  end

  describe 'is_admin?', code: true  do
    it { expect(@user.is_admin?).to be_falsey }

    it 'is true' do
      @admin = create(:pixi_user, user_type_code: 'AD') 
      expect(@admin.is_admin?).to be_truthy
    end
  end

  describe "listing associations" do
    before do
      @buyer = create(:pixi_user) 
      @pixter = create(:pixi_user, user_type_code: 'PT') 
      @listing = create(:listing, seller_id: @user.id)
      @pp_listing = create(:listing, seller_id: @user.id, pixan_id: @pixter.id)
      @sold_listing = create(:listing, seller_id: @buyer.id, status: 'sold')
    end

    it 'accesses listings' do 
      expect(@user.active_listings).to include(@listing) 
      expect(@buyer.active_listings).not_to include(@sold_listing)
      expect(@user.pixi_posted_listings).to include(@pp_listing)
      expect(@user.pixi_posted_listings).not_to include(@listing)
    end
  end

  describe "invoice associations" do
    before do
      @buyer = create(:pixi_user) 
      @listing = create(:listing, seller_id: @user.id)
    end

    it 'should not have unpaid invoices' do
      expect(@user.unpaid_invoices).to be_empty
    end

    it 'should have only unpaid invoices' do
      @invoice = @user.invoices.create attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, status: 'unpaid')
      expect(@user.unpaid_invoices).not_to be_empty
      expect(@buyer.paid_invoices).to be_empty
      expect(@buyer.has_unpaid_invoices?).to be_truthy 
    end

    it 'should have paid invoices' do
      @account = @user.bank_accounts.create attributes_for :bank_account
      @invoice = @user.invoices.create attributes_for(:invoice, pixi_id: @listing.pixi_id, buyer_id: @buyer.id, 
        bank_account_id: @account.id, status: 'paid')
      expect(@user.paid_invoices).not_to be_empty
      expect(@user.unpaid_invoices).to be_empty
      expect(@buyer.has_unpaid_invoices?).not_to be_truthy 
    end
  end

  describe "get by type" do
    it "includes pixans" do
      @user.user_type_code = 'PX'
      @user.save
      expect(User.get_by_type(['PX', 'PT'])).not_to be_empty
    end

    it "includes pixans" do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_by_type('BUS')).not_to be_empty
    end

    it "includes all" do
      expect(User.get_by_type(nil)).not_to be_empty
    end

    it "does not include pixans" do
      expect(User.get_by_type(['PX', 'PT'])).not_to include(@user)
    end
  end

  describe 'type_descr' do
    it "shows description" do
      create :user_type
      @user.user_type_code = 'PX'
      expect(@user.type_descr).to eq 'Pixan'
    end

    it "does not show description" do
      expect(@user.type_descr).to be_nil
    end
  end

  describe "find_user" do
    it 'finds a user' do
      expect(User.find_user(@user.id)).not_to be_nil
    end

    it 'does not find user' do
      expect(User.find_user(0)).to be_nil
    end
  end

  describe 'async_send_notifications' do

    def send_mailer usr
      @mailer = double(UserMailer)
      allow(UserMailer).to receive(:delay).and_return(@mailer)
      allow(@mailer).to receive(:welcome_email).with(usr).and_return(@mailer)
    end

    it 'adds dr pixi points' do
      @user = create :pixi_user 
      expect(@user.user_pixi_points.count).not_to eq(0)
      expect(@user.user_pixi_points.find_by_code('dr').code).to eq('dr')
      expect(@user.user_pixi_points.find_by_code('fr')).to be_nil
    end

    it 'adds fr pixi points' do
      @pixi_user = create :pixi_user, uid: '11111' 
      expect(@pixi_user.user_pixi_points.find_by_code('fr').code).to eq('fr')
      expect(@pixi_user.user_pixi_points.find_by_code('dr')).to be_nil
    end

    it 'delivers the welcome message' do
      @pixi_user = create :pixi_user, uid: '11111' 
      send_mailer @user if @pixi_user.fb_user?
    end
  end

  describe "post associations" do
    let(:listing) { create :listing, seller_id: @user.id }
    let(:newer_listing) { create :listing, seller_id: @user.id }
    let(:recipient) { create :pixi_user, first_name: 'Wilson' }
    let(:conversation) { create :conversation, user: @user, recipient: recipient, listing: listing, pixi_id: listing.pixi_id }
    let!(:older_post) do 
      create(:post, user: @user, recipient: recipient, listing: listing, pixi_id: listing.pixi_id, created_at: 1.day.ago, conversation_id: conversation.id, conversation: conversation)
    end

    let!(:newer_post) do
      create(:post, user: @user, recipient: recipient, listing: newer_listing, pixi_id: newer_listing.pixi_id, created_at: 1.hour.ago, conversation_id: conversation.id, conversation: conversation)
    end

    it "should have the right posts in the right order" do
      expect(@user.posts).to eq([newer_post, older_post])
    end

    it "should destroy associated posts" do
      posts = @user.posts.dup
      @user.destroy
      expect(posts).not_to be_empty

      posts.each do |post|
        expect(Post.find_by_id(post.id)).to be_nil
      end
    end
  end

  describe "exporting as CSV" do
    it "exports data as CSV file" do
      csv_string = @user.as_csv
      expect(csv_string.keys).to match_array(["Name", "Email", "Type", "Zip", "Birth Date", "Enrolled"])
      expect(csv_string.values).to match_array([@user.name, @user.email, @user.type_descr, @user.home_zip,
                                   @user.birth_dt, @user.nice_date(@user.created_at)])
      @user.current_sign_in_at = Time.now
      csv_string = @user.as_csv
      expect(csv_string.keys).to include "Last Login"
      expect(csv_string.values).to include @user.nice_date(@user.current_sign_in_at)
    end

    it "does not export any user data" do
      usr = build :user
      csv = usr.as_csv
      expect(csv.values).to include(nil)
    end
  end

  describe "get conversations" do
    before(:each) do
      @user = create :pixi_user
      @recipient = create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tom.davis4@pixitest.com'
      @buyer = create :pixi_user, first_name: 'Jack', last_name: 'Smith', email: 'jack.smith97@pixitest.com'
      @listing = create :listing, seller_id: @user.id, title: 'Big Guitar'
      @listing2 = create :listing, seller_id: @recipient.id, title: 'Small Guitar'
      @conversation = @listing.conversations.create attributes_for :conversation, user_id: @recipient.id, recipient_id: @user.id
      @conversation2 = @listing2.conversations.create attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id 
      @post = @conversation.posts.create attributes_for :post, user_id: @recipient.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
      @post2 = @conversation2.posts.create attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @listing2.pixi_id

    end

    it "gets all conversations for user" do
      expect(@user.get_conversations.count).to eql(2)
    end

    it "gets right sent conversations for user" do
      expect(@user.get_conversations).to include(@conversation2)
    end

    it "gets right received conversations for user" do
      expect(@user.get_conversations).to include(@conversation)
    end

    it "gets no conversations when there are none" do
      Conversation.destroy_all
      expect(@user.get_conversations).to eql([])
    end
  end

  describe "is_admin?" do
    it "returns true for admin" do
      @user = create :admin
      @user.user_type_code = 'AD'
      @user.save!
      expect(@user.is_admin?).to be_truthy
    end

    it "returns false for non-admin" do
      @user = create :pixi_user
      expect(@user.is_admin?).to be_falsey
    end
  end

  describe "is_business?" do
    it "returns true for business" do
      @user = create :pixi_user, birth_date: nil, gender: nil, user_type_code: 'BUS', business_name: 'Company A'
      expect(@user.is_business?).to be_truthy
    end

    it "returns false for non-business" do
      @user = create :pixi_user
      expect(@user.is_business?).to be_falsey
    end
  end

  describe "url" do
    it 'generates url' do
      @user.user_url = @user.name
      expect(@user.url).to eq @user.name.downcase.gsub!(/\s+/, "") + '1'
    end

    it 'generates unique url' do
      @user.user_url = @user.name
      @user.save!
      user2 = create :pixi_user, first_name: @user.first_name, last_name: @user.last_name
      expect(user2.url).not_to eq @user.url
    end

    it 'generates url for business' do
      user = build :contact_user, user_type_code: 'BUS', business_name: 'Toy Shack + Gifts'
      user.save!
      expect(user.url).to eq NameParse.transliterate(user.business_name, false).gsub!(/\s+/, "")
    end

    it 'shows full url path' do
      expect(@user.user_url).to eq 'localhost:3000/mbr/' + @user.url
    end
  end

  describe 'code_type' do
    it "shows code" do
      @user.user_type_code = 'px'
      expect(@user.code_type).to eq 'PX'
    end

    it "shows default code" do
      usr = build :user
      expect(usr.code_type).not_to be_nil
    end
  end

  describe 'guest' do
    before :each, run: true do
      @test_user = build :pixi_user, guest: true
    end

    it { expect(@user.guest?).not_to be_truthy }
    it 'returns true', run: true do
      expect(@test_user.guest?).to be_truthy
    end
  end

  describe 'new_guest' do
    it { expect(User.new_guest.status).to eq 'inactive' }
    it { expect(User.new_guest.guest?).to be_truthy }
    it 'saves guest user' do
      user = User.new_guest
      expect(User.where(status: 'inactive').count).to eq 1
    end
  end

  describe 'move_to' do
    before :each, run: true do
      @usr = create :pixi_user
    end
    it 'moves user pixipost content', run: true do
      @pixi_post_zip = create(:pixi_post_zip)
      attr = {"preferred_date"=>"04/05/2015", "preferred_time"=>"13:00:00", "alt_date"=>"", "alt_time"=>"12:00:00", 
      "quantity"=>"2", "value"=>"200.0", "description"=>"xbox 360 box.", "address"=>"123 Elm", "address2"=>"", "city"=>"LA", "state"=>"CA", 
      "zip"=>"90201", "home_phone"=>"4155551212", "mobile_phone"=>"", "user_id"=>""}
      @post = PixiPost.add_post(attr, User.new)
      @post.save!
      @post.user.move_to(@usr)
      expect(@usr.pixi_posts.size).to eq 1
      expect(@usr.contacts.size).to eq 1
      expect(@post.user.pixi_posts.size).to eq 0
    end
    it 'moves user temp listings', run: true do
      @listing = TempListing.add_listing(set_temp_attr(''), TempListing.new)
      @listing.save!
      @listing.user.move_to(@usr)
      expect(@usr.temp_listings.size).to eq 1
      expect(@listing.user.temp_listings.size).to eq 0
    end
    it 'does not move user content' do
      usr = create :pixi_user
      usr.move_to(nil)
      expect(usr.contacts.size).to eq 1
    end
  end

  describe "user status" do
    it { expect(User.active).not_to be_nil }
    it 'have no active users' do
      @user.update_attribute(:status, 'inactive')
      expect(User.active).to be_blank
    end
  end

  describe 'set_flds' do
    let(:user) { build :pixi_user }
    it { expect{ user.save }.to change{ user.status } }
    it { expect{ user.save }.to change{ user.user_type_code } }
    it 'sets url' do
      user.save!
      expect( user.url ).not_to be_blank
    end
    it 'does not set user_type' do
      user.user_type_code = 'AD'
      expect{ user.save }.not_to change { user.user_type_code } 
    end
    it 'does not set status for guest' do
      user.guest = true  
      expect{ user.save }.not_to change{ user.status } 
    end
    it 'does not set status for inactive users' do
      user.status = 'inactive'  
      expect{ user.save }.not_to change{ user.status } 
    end
  end

  describe 'primary_address', address: true do
    it { expect(@user.primary_address).not_to be_blank }
    it 'has no address' do
      user = build :pixi_user
      expect(user.primary_address).to be_blank
    end
  end

  describe 'site_name' do
    it { expect(@user.site_name).not_to be_nil }
    it 'returns nil' do
      @user.home_zip = '00000'
      expect(@user.site_name).to be_nil
    end
  end

  describe 'get_sellers' do
    before :each, run: true do
      @listing = create :listing, seller_id: @user.id
      @site = create :site, site_type_code: 'city', name: 'SF'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '101 California', city: 'SF', state: 'CA', zip: '94111'))
      @listing.update_attribute(:site_id, @site.id)
    end
    it { expect(User.get_sellers(Listing.all)).to be_empty }
    it 'has no business users', run: true do
      expect(User.get_sellers(Listing.all)).to be_empty
    end
    it 'has a business user in different site', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(Listing.all)).to be_empty
    end
    it 'has a business user in different category', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(Listing.all)).to be_empty
    end
    it 'has a business user w insufficient pixis', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      expect(User.get_sellers(Listing.all)).to be_empty
    end
    it 'has a business user w sufficient pixis', run: true do
      @user.update_attribute(:user_type_code, 'BUS')
      listing = create :listing, seller_id: @user.id, title: 'Leather Coat', site_id: @site.id, category_id: @listing.category_id
      listing = create :listing, seller_id: @user.id, title: 'Fur Coat', site_id: @site.id, category_id: @listing.category_id
      @user.reload
      expect(User.get_sellers(Listing.all)).not_to be_empty
    end
  end

  describe "is_followed?" do
    before :each do
      @user2 = create :contact_user
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns users that are following the seller" do
      expect(@seller.is_followed?(@user)).to be_truthy
    end

    it "does not return users that aren't following the seller" do
      expect(@seller.is_followed?(@user2)).to be_falsey
    end
  end

  describe "is_following?" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @seller2 = create(:contact_user, user_type_code: 'BUS', business_name: 'Another Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns users that are following the seller" do
      expect(@user.is_following?(@seller)).to be_truthy
    end

    it "does not return users that aren't following the seller" do
      expect(@user.is_following?(@seller2)).to be_falsey
    end
  end

  describe "get_by_ftype" do
    it "calls get_by_seller if ftype='seller'" do
      expect(User).to receive :get_by_seller
      User.get_by_ftype('seller', nil, 'active')
    end

    it "calls get_by_user otherwise" do
      expect(User).to receive :get_by_user
      User.get_by_ftype('buyer', nil, 'active')
    end
  end

  describe "get_by_seller" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "'active' status returns users following the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id, 'active')).to include @user
    end

    it "'removed' status returns users that unfollowed the seller_id provided" do
      @favorite_seller.update_attribute(:status, 'removed')
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id, 'removed')).to include @user
    end

    it "returns nil if there are no users following the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_seller(@favorite_seller.seller_id - 1, 'active')).to be_empty
    end
    
    it "returns all followers if seller_id is blank" do
      expect(UserProcessor.new(nil).get_by_seller(nil, 'active')).to include @user
    end
  end

  describe "get_by_user" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "'active' status returns sellers followed by the user_id provided" do
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id, 'active')).to include @seller
    end

    it "'removed' status returns sellers that were unfollowed by the user_id provided" do
      @favorite_seller.update_attribute(:status, 'removed')
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id, 'removed')).to include @seller
    end

    it "returns nil if there are no sellers followed by the seller_id provided" do
      expect(UserProcessor.new(nil).get_by_user(@favorite_seller.user_id - 1, 'active')).to be_empty
    end
    
    it "returns all sellers if seller_id is blank" do
      expect(UserProcessor.new(nil).get_by_user(nil, 'active')).to include @seller
    end
  end

  describe "date_followed" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns date followed if available" do
      expect(@user.date_followed(@seller).to_s).to eq @favorite_seller.updated_at.to_s
    end

    it "returns nil otherwise" do
      expect(@seller.date_followed(@user)).to be_nil
    end
  end

  describe "favorite_seller_id" do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it "returns id of FavoriteSeller object if available" do
      expect(@user.favorite_seller_id(@seller)).to eq @favorite_seller.id
    end

    it "returns nil otherwise" do
      expect(@seller.favorite_seller_id(@user)).to be_nil
    end
  end

  describe 'get_follow_status' do
    before :each do
      @seller = create(:contact_user, user_type_code: 'BUS', business_name: 'Test')
      @favorite_seller = create(:favorite_seller, user_id: @user.id, seller_id: @seller.id)
    end

    it { expect(@user.get_follow_status('seller', @seller.id)).to eq 'active' }
    it { expect(@seller.get_follow_status('follower', @user.id)).to eq 'active' }
    context 'inactive' do
      it 'returns inactive following' do
        @favorite_seller.update_attribute(:status, 'inactive')
        expect(@user.get_follow_status('seller', @seller.id)).to eq 'inactive' 
      end
      it 'returns inactive followed' do
        @favorite_seller.update_attribute(:status, 'inactive')
        expect(@seller.get_follow_status('follower', @user.id)).to eq 'inactive' 
      end
    end
  end

  describe "get by url", url: true do
    it_behaves_like 'a url', 'User', :contact_user, true
  end

  describe 'board_fields' do
    it "contains correct fields" do
      usr = User.active.board_fields
      expect(usr.first.id).to eq @user.id  
    end
    it { expect(User.active.board_fields).not_to include @user.created_at }
  end

  describe "has_ship_address?" do
    it "returns true if ShipAddress record exists" do
      @user.ship_addresses.create
      expect(@user.has_ship_address?).to be_truthy
    end

    it "returns false otherwise" do
      @user.ship_addresses.delete_all
      expect(@user.has_ship_address?).to be_falsey
    end
  end

  describe "counter cache" do
    it "has a listing counter cache" do
      create :listing, seller_id: @user.id, quantity: 1, status: 'active'
      User.find_each { |usr| User.reset_counters(usr.id, :active_listings) }
      expect(@user.reload.active_listings_count).to eq 1
    end

    it "updates active_card_accounts cache on create" do
      @user.card_accounts.create attributes_for :card_account
      expect(@user.reload.active_card_accounts_count).to eq 1
    end

    it "updates active_card_accounts cache on update" do
      card_account = @user.card_accounts.create attributes_for :card_account
      card_account.update_attributes(status: 'inactive')
      expect(@user.reload.active_card_accounts_count).to eq 0
    end
  end

  describe 'nearest stores' do
    before :each do
      allow_any_instance_of(Contact).to receive(:near).and_return([1,1])
      allow_any_instance_of(User).to receive(:get_nearest_stores).and_return(@usr)
    end
    it 'has a nearest store' do
      @usr = create :business_user
      expect(User.get_nearest_stores('90201').count).to be < 2
    end
    it { expect(User.get_nearest_stores('94107')).not_to include @user }
  end
end
