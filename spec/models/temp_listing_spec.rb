require 'spec_helper'

describe TempListing do
  before(:each) do
    @category = FactoryGirl.create(:category, pixi_type: 'basic') 
    @temp_listing = FactoryGirl.create(:temp_listing)
  end

  subject { @temp_listing }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:site_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:alias_name) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:show_alias_flg) }
  it { should respond_to(:status) }
  it { should respond_to(:price) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:show_phone_flg) }
  it { should respond_to(:category_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:parent_pixi_id) }
  it { should respond_to(:post_ip) }
  it { should respond_to(:event_start_date) }
  it { should respond_to(:event_end_date) }
  it { should respond_to(:compensation) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:event_start_time) }
  it { should respond_to(:event_end_time) }
  it { should respond_to(:year_built) }
  it { should respond_to(:pixan_id) }
  it { should respond_to(:job_type) }

  it { should respond_to(:user) }
  it { should respond_to(:site) }
  it { should respond_to(:transaction) }
  it { should respond_to(:pictures) }
  it { should respond_to(:category) }
  it { should respond_to(:set_flds) }
  it { should respond_to(:generate_token) }
  it { should respond_to(:site_listings) }

  describe "when price is not a number" do
    before { @temp_listing.price = "$500" }
    it { should_not be_valid }
  end
  
  describe "when price is less than 0" do
    before { @temp_listing.price = -500.00 }
    it { should_not be_valid }
  end
  
  describe "when price is greater than 1M" do
    before { @temp_listing.price = 5000000.00 }
    it { should_not be_valid }
  end
  
  describe "when price is greater than 0 but less than 1M" do
    before { @temp_listing.price = 500.00 }
    it { should be_valid }
  end
  
  describe "when site_id is empty" do
    before { @temp_listing.site_id = "" }
    it { should_not be_valid }
  end
  
  describe "when site_id is entered" do
    before { @temp_listing.site_id = 1 }
    it { @temp_listing.site_id.should == 1 }
  end

  describe "when seller_id is empty" do
    before { @temp_listing.seller_id = "" }
    it { should_not be_valid }
  end

  describe "when seller_id is entered" do
    before { @temp_listing.seller_id = 1 }
    it { @temp_listing.seller_id.should == 1 }
  end

  describe "when transaction_id is entered" do
    before { @temp_listing.transaction_id = 1 }
    it { @temp_listing.transaction_id.should == 1 }
  end

  describe "when start_date is empty" do
    before { @temp_listing.start_date = "" }
    it { should_not be_valid }
  end

  describe "when start_date is entered" do
    before { @temp_listing.start_date = Time.now }
    it { should be_valid }
  end

  describe "when title is empty" do
    before { @temp_listing.title = "" }
    it { should_not be_valid }
  end

  describe "when title is entered" do 
    before { @temp_listing.title = "chair" }
    it { @temp_listing.title.should == "chair" }
  end

  describe "when title is too large" do
    before { @temp_listing.title = "a" * 81 }
    it { should_not be_valid }
  end

  describe "when description is entered" do 
    before { @temp_listing.description = "chair" }
    it { @temp_listing.description.should == "chair" }
  end

  describe "when description is empty" do
    before { @temp_listing.description = "" }
    it { should_not be_valid }
  end

  describe "when category_id is entered" do 
    before { @temp_listing.category_id = 1 }
    it { @temp_listing.category_id.should == 1 }
  end

  describe "when category_id is empty" do
    before { @temp_listing.category_id = "" }
    it { should_not be_valid }
  end

  describe "should not include invalid site listings" do 
    it { TempListing.get_by_site(0).should_not include @temp_listing } 
  end

  describe "should include site listings" do
    it { TempListing.get_by_site(@temp_listing.site.id).should_not be_empty }
  end

  describe "should include seller listings" do
    it { TempListing.get_by_seller(1).should_not be_empty }
  end

  describe "should not include incorrect seller listings" do 
    it { TempListing.get_by_seller(0).should_not include @temp_listing } 
  end

  describe "get_by_status should not include inactive listings" do
    temp_listing = FactoryGirl.create :listing, :description=>'stuff', :status=>'inactive'
    it { TempListing.get_by_status('active').should_not include (temp_listing) }
  end

  describe "should return correct site name" do 
    it { @temp_listing.site_name.should_not be_empty } 
  end

  describe "should not find correct site name" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { temp_listing.site_name.should be_nil } 
  end

  describe "should find correct category name" do 
    it { @temp_listing.category_name.should == @category.name.titleize } 
  end

  describe "should not find correct category name" do 
    temp_listing = FactoryGirl.build :temp_listing, category_id: nil
    it { temp_listing.category_name.should be_nil } 
  end

  describe "should find correct seller name" do 
    let(:user) { FactoryGirl.create(:pixi_user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    it { temp_listing.seller_name.should == user.name } 
  end

  describe "should not find correct seller name" do 
    temp_listing = FactoryGirl.create :temp_listing, seller_id: 100
    it { temp_listing.seller_name.should be_nil } 
  end

  describe "should find correct seller photo" do 
    let(:user) { FactoryGirl.create(:pixi_user) }
    let(:temp_listing) { FactoryGirl.create(:temp_listing, seller_id: user.id) }
    it { temp_listing.seller_photo.should_not be_nil } 
  end

  describe "should not find correct seller photo" do 
    temp_listing = FactoryGirl.create :temp_listing, seller_id: 100
    it { temp_listing.seller_photo.should be_nil } 
  end

  describe "should have a transaction" do 
    it { @temp_listing.has_transaction?.should be_true }
  end

  describe "should not have a transaction" do 
    temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil
    it { temp_listing.has_transaction?.should_not be_true }
  end

  describe "should verify if seller name is an alias" do 
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'yes'
    it { temp_listing.alias?.should be_true }
  end

  describe "should not have an alias" do 
    temp_listing = FactoryGirl.create :temp_listing, show_alias_flg: 'no'
    it { temp_listing.alias?.should_not be_true }
  end

  describe "seller?" do 
    let(:user) { FactoryGirl.create :pixi_user }
    let(:user2) { FactoryGirl.create :pixi_user, first_name: 'Kate', last_name: 'Davis', email: 'katedavis@pixitest.com' }
    let(:temp_listing) { FactoryGirl.create :temp_listing, seller_id: user.id }

    it "should verify user is seller" do 
      temp_listing.seller?(user).should be_true 
    end

    it "should not verify user is seller" do 
      temp_listing.seller?(user2).should_not be_true 
    end
  end

  describe "should return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 500
    it { temp_listing.brief_descr.length.should == 100 }
  end

  describe "should not return a short description" do 
    temp_listing = FactoryGirl.create :temp_listing, description: 'qqq'
    it { temp_listing.brief_descr.length.should_not == 100 }
  end

  describe "should return a summary" do 
    temp_listing = FactoryGirl.create :temp_listing, description: "a" * 500
    it { temp_listing.summary.should be_true }
  end

  describe "should not return a summary" do 
    temp_listing = FactoryGirl.build :temp_listing, description: nil
    it { temp_listing.summary.should_not be_true }
  end

  describe "should return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'guitar for sale'
    it { temp_listing.nice_title.should == 'Guitar For Sale' }
  end

  describe "should not return a nice title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: 'qqq'
    it { temp_listing.nice_title.should_not == 'Guitar For Sale' }
  end

  describe "should return a short title" do 
    temp_listing = FactoryGirl.create :temp_listing, title: "a" * 40
    it { temp_listing.short_title.length.should == 18 }
  end

  describe "should not return a short title" do 
    temp_listing = FactoryGirl.build :temp_listing, title: 'qqq'
    it { temp_listing.short_title.length.should_not == 18 }
  end

  describe "set flds" do 
    let(:temp_listing) { FactoryGirl.create :temp_listing, status: "" }

    it "should call set flds" do 
      temp_listing.status.should == "new"
    end
  end

  describe "invalid set flds" do 
    let(:temp_listing) { FactoryGirl.build :temp_listing, title: nil, status: "" }
    
    it "should not call set flds" do 
      temp_listing.save
      temp_listing.status.should_not == 'new'
    end
  end 

  describe "should return site count > 0" do 
    temp_listing = FactoryGirl.create :temp_listing, site_id: 100
    it { temp_listing.get_site_count.should == 0 } 
  end

  describe "should not return site count > 0" do 
    it { @temp_listing.get_site_count.should_not == 0 } 
  end

  describe "transactions" do
    let(:transaction) { FactoryGirl.create :transaction }
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    context "get_by_status should include new listings" do
      it { TempListing.get_by_status('active').should_not be_empty } 
    end

    it "should not submit order" do 
      @temp_listing.category_id = @cat.id
      @temp_listing.submit_order(nil).should_not be_true
    end

    it "should submit order" do 
      @temp_listing.submit_order(transaction.id).should be_true
    end

    it "should resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: transaction.id
      temp_listing.resubmit_order.should be_true 
    end

    it "should not resubmit order" do 
      temp_listing = FactoryGirl.create :temp_listing, transaction_id: nil, category_id: @cat.id
      temp_listing.resubmit_order.should_not be_true
    end
  end

  describe "approved order" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "approve order should not return approved status" do 
      @temp_listing.approve_order(nil)
      @temp_listing.status.should_not == 'approved'
    end

    it "approve order should return approved status" do 
      temp_listing.approve_order(user)
      temp_listing.status.should == 'approved'
    end
  end

  describe "deny order" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "deny order should not return denied status" do 
      @temp_listing.deny_order(nil)
      @temp_listing.status.should_not == 'denied'
    end

    it "deny order should return denied status" do 
      temp_listing.deny_order(user)
      temp_listing.status.should == 'denied'
    end
  end

  describe "dup pixi" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "does not return new listing" do 
      listing = FactoryGirl.build :temp_listing, seller_id: user.id 
      listing.dup_pixi(true).should_not be_true
    end

    it "returns new listing" do 
      temp_listing.dup_pixi(true).should be_true
    end
  end

  describe "post to board" do
    let(:user) { FactoryGirl.create :pixi_user }
    let(:temp_listing) { FactoryGirl.create :temp_listing_with_transaction, seller_id: user.id }

    it "post to board should not return new listing" do 
      temp_listing.post_to_board.should_not be_true
    end

    it "post to board should return new listing" do 
      temp_listing.status = 'approved'
      temp_listing.post_to_board.should be_true
    end
  end

  describe "should verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'new'
    it { temp_listing.new_status?.should be_true }
  end

  describe "should not verify new status" do 
    temp_listing = FactoryGirl.build :temp_listing, status: 'pending'
    it { temp_listing.new_status?.should_not be_true }
  end

  describe "must have pictures" do
    let(:temp_listing) { FactoryGirl.build :invalid_temp_listing }

    it "should not save w/o at least one picture" do
      picture = temp_listing.pictures.build
      temp_listing.should_not be_valid
    end

    it "should save with at least one picture" do
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      temp_listing.should be_valid
    end
  end

  describe "delete photo" do
    let(:temp_listing) { FactoryGirl.create :temp_listing }

    it "should not delete photo" do 
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id).should_not be_true
    end

    it "should delete photo" do 
      picture = temp_listing.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      temp_listing.save
      pic = temp_listing.pictures.first
      temp_listing.delete_photo(pic.id).should be_true
    end
  end

  describe 'premium?' do
    it 'should return true' do
      temp_listing = FactoryGirl.create(:temp_listing, category_id: @category.id) 
      temp_listing.premium?.should be_true
    end

    it 'should not return true' do
      @temp_listing.premium?.should_not be_true
    end
  end

  describe 'pictures' do
    before(:each) do
      @sr = @temp_listing.pictures.create FactoryGirl.attributes_for(:picture)
    end
				            
    it "should have pictures" do 
      @temp_listing.pictures.should include(@sr)
    end

    it "should not have too many pictures" do 
      20.times { @temp_listing.pictures.build FactoryGirl.attributes_for(:picture) }
      @temp_listing.save
      @temp_listing.should_not be_valid
    end

    it "should destroy associated pictures" do
      @temp_listing.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end  
  end  

  describe '.same_day?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Events', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
    end

    it "should respond to same_day? method" do
      @temp_listing.should respond_to(:same_day?)
    end

    it "should be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today
      @temp_listing.same_day?.should be_true
    end

    it "should not be the same day" do
      @temp_listing.event_start_date = Date.today
      @temp_listing.event_end_date = Date.today+1.day
      @temp_listing.same_day?.should be_false 
    end
  end

  describe '.pending?' do
    it "is not pending" do
      @temp_listing.pending?.should be_false 
    end

    it "is pending" do
      @temp_listing.status = 'pending'
      @temp_listing.pending?.should be_true 
    end
  end

  describe '.edit?' do
    it "is not edit" do
      @temp_listing.edit?.should be_false 
    end

    it "is edit" do
      @temp_listing.status = 'edit'
      @temp_listing.edit?.should be_true 
    end
  end

  describe '.event?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', pixi_type: 'premium') 
    end

    it "is not an event" do
      @temp_listing.event?.should be_false 
    end

    it "is an event" do
      @temp_listing.category_id = @cat.id
      @temp_listing.event?.should be_true 
    end
  end

  describe '.has_year?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Automotive', pixi_type: 'premium') 
    end

    it "does not have a year" do
      @temp_listing.has_year?.should be_false 
    end

    it "has a year" do
      @temp_listing.category_id = @cat.id
      @temp_listing.has_year?.should be_true 
    end
  end

  describe '.job?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    it "is not a job" do
      @temp_listing.job?.should be_false 
    end

    it "is a job" do
      @temp_listing.category_id = @cat.id
      @temp_listing.job?.should be_true 
    end
  end

  describe '.free?' do
    before do
      @cat = FactoryGirl.create(:category, name: 'Jobs', pixi_type: 'premium') 
    end

    it "is not free" do
      @temp_listing.category_id = @cat.id
      @temp_listing.free?.should be_false 
    end

    it "is free" do
      @temp_listing.free?.should be_true 
    end
  end

  describe "is not pixi_post" do 
    it { @temp_listing.pixi_post?.should_not be_true }
  end

  describe "is a pixi_post" do 
    before do 
      @pixan = FactoryGirl.create(:contact_user) 
      @temp_listing.pixan_id = @pixan.id 
    end
    it { @temp_listing.has_pixi_post?.should be_true }
  end

  describe '.start_date?' do
    it "has no start date" do
      @temp_listing.start_date?.should be_false
    end

    it "has a start date" do
      @temp_listing.event_start_date = Time.now
      @temp_listing.start_date?.should be_true
    end
  end

  describe "date validations" do
    before do
      @cat = FactoryGirl.create(:category, name: 'Event', pixi_type: 'premium') 
      @temp_listing.category_id = @cat.id
      @temp_listing.event_end_date = Date.today+3.days 
      @temp_listing.event_start_time = Time.now+2.hours
      @temp_listing.event_end_time = Time.now+3.hours
    end

    describe 'start date' do
      it "has valid start date" do
        @temp_listing.event_start_date = Date.today+2.days
        @temp_listing.should be_valid
      end

      it "should reject a bad start date" do
        @temp_listing.event_start_date = Date.today-2.days
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a start date" do
        @temp_listing.event_start_date = nil
        @temp_listing.should_not be_valid
      end
    end

    describe 'end date' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_start_time = Time.now+2.hours
        @temp_listing.event_end_time = Time.now+3.hours
      end

      it "has valid end date" do
        @temp_listing.event_end_date = Date.today+3.days
        @temp_listing.should be_valid
      end

      it "should reject a bad end date" do
        @temp_listing.event_end_date = ''
        @temp_listing.should_not be_valid
      end

      it "should reject end date < start date" do
        @temp_listing.event_end_date = Date.today-2.days
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a end date" do
        @temp_listing.event_end_date = nil
        @temp_listing.should_not be_valid
      end
    end

    describe 'start time' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_end_date = Date.today+3.days 
        @temp_listing.event_end_time = Time.now+3.hours
      end

      it "has valid start time" do
        @temp_listing.event_start_time = Time.now+2.hours
        @temp_listing.should be_valid
      end

      it "should reject a bad start time" do
        @temp_listing.event_start_time = ''
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a start time" do
        @temp_listing.event_start_time = nil
        @temp_listing.should_not be_valid
      end
    end

    describe 'end time' do
      before do
        @temp_listing.event_start_date = Date.today+2.days 
        @temp_listing.event_end_date = Date.today+3.days 
        @temp_listing.event_start_time = Time.now+2.hours
      end

      it "has valid end time" do
        @temp_listing.event_end_time = Time.now+3.hours
        @temp_listing.should be_valid
      end

      it "should reject a bad end time" do
        @temp_listing.event_end_time = ''
        @temp_listing.should_not be_valid
      end

      it "should reject end time < start time" do
        @temp_listing.event_end_date = @temp_listing.event_start_date
        @temp_listing.event_end_time = Time.now.advance(:hours => -2)
        @temp_listing.should_not be_valid
      end

      it "should not be valid without a end time" do
        @temp_listing.event_end_time = nil
        @temp_listing.should_not be_valid
      end
    end
  end
end
