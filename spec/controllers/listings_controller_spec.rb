require 'login_user_spec'

describe ListingsController do
  include LoginTestUser

  def mock_listing(stubs={})
    (@mock_listing ||= mock_model(Listing, stubs).as_null_object).tap do |listing|
      listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_temp_listing(stubs={})
    (@mock_temp_listing ||= mock_model(TempListing, stubs).as_null_object).tap do |temp_listing|
      temp_listing.stub(stubs) unless stubs.empty?
    end
  end

  def mock_user(stubs={})
    (@mock_user ||= mock_model(User, stubs).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

  before(:each) do
    log_in_test_user
    @listing = stub_model(Listing, :id=>1, site_id: 1, seller_id: 1, title: "Guitar for Sale", description: "Guitar for Sale")
  end

  describe 'GET index' do
    before(:each) do
      @listings = mock("listings")
      Listing.stub!(:active).and_return(@listings)
    end

    def do_get
      get :index
    end

    it "renders the :index view" do
      do_get
      response.should render_template :index
    end

    it "should assign @listings" do
      Listing.should_receive(:active).and_return(@listings)
      do_get 
      assigns(:listings).should_not be_nil
    end
  end

  describe 'GET seller/:user_id' do
    before :each do
      @listings = mock("listings")
      @temp_listings = mock("temp_listings")
      @user = stub_model(User)
      User.stub!(:find).and_return(@user)
      @user.stub!(:listings).and_return( @listings )
      @user.stub!(:temp_listings).and_return( @temp_listings )
    end

    def do_get
      get :seller, :user_id => '1'
    end

    it "renders the :seller view" do
      do_get
      response.should render_template :seller
    end

    it "should assign @user" do
      do_get 
      assigns(:user).should_not be_nil
    end

    it "should assign @listings" do
      do_get 
      assigns(:listings).should_not be_nil
    end

    it "should assign @temp_listings" do
      do_get 
      assigns(:temp_listings).should_not be_nil
    end

    it "should show the requested listings" do
      do_get
      response.should be_success
    end

    it "should load the requested user" do
      User.should_receive(:find).with('1').and_return(@user)
      do_get
    end
  end

  describe 'GET show/:id' do
    before :each do
      @photo = stub_model(Picture)
      Listing.stub!(:find).and_return( @listing )
      @listing.stub!(:pictures).and_return( @photo )
    end

    def do_get
      get :show, :id => @listing
    end

    it "should show the requested listing" do
      do_get
      response.should be_success
    end

    it "should load the requested listing" do
      Listing.stub(:find).with(@listing.id).and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @photo" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "show action should render show template" do
      do_get
      response.should render_template(:show)
    end
  end

  describe "GET 'new'" do

    before :each do
      @user = stub_model(User)
      User.stub!(:find).and_return(@user)
      Listing.stub!(:new).and_return( @listing )
      @picture = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@picture)
    end

    def do_get
      get :new, :user_id => '3' #, :site_id => 50 
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil
    end

    it "should assign @user" do
      do_get
      assigns(:user).should_not be_nil
    end

    it "should assign @picture" do
      do_get
      assigns(:listing).pictures.should_not be_nil
    end

    it "new action should render new template" do
      do_get
      response.should render_template(:new)
    end
  end

  describe "POST create" do
    
    context 'failure' do
      
      before :each do
        Listing.stub!(:save).and_return(false)
      end

      def do_create
        post :create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "should render the new template" do
        do_create
        response.should render_template(:new)
      end
    end

    context 'success' do

      before :each do
        Listing.stub!(:save).and_return(true)
      end

      def do_create
        post :create, :listing => { 'title'=>'test', 'description'=>'test' }
      end

      it "should load the requested listing" do
        Listing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
      end

      it "should assign @listing" do
        do_create
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the created listing" do
        Listing.stub(:new).with({'title'=>'test', 'description'=>'test' }) { mock_listing(:save => true) }
        do_create
        response.should be_redirect
      end

      it "should change listing count" do
        lambda do
          do_create
          should change(Listing, :count).by(1)
        end
      end
    end
  end

  describe "GET 'edit/:id'" do

    before :each do
      Listing.stub!(:find).and_return( @listing )
      @picture = stub_model(Picture)
      @listing.stub_chain(:pictures, :build).and_return(@picture)
    end

    def do_get
      get :edit, :id => '1'
    end

    it "should load the requested listing" do
      Listing.should_receive(:find).with('1').and_return(@listing)
      do_get
    end

    it "should assign @listing" do
      do_get
      assigns(:listing).should_not be_nil 
    end

    it "should load the requested listing" do
      do_get
      response.should be_success
    end
  end

  describe "PUT /:id" do
    before (:each) do
      Listing.stub!(:find).and_return( @listing )
    end

    context "with valid params" do
      before (:each) do
        @listing.stub(:update_attributes).and_return(true)
      end

      def do_update
        put :update, :id => "1", :listing => {'title'=>'test', 'description' => 'test'}
      end

      it "should load the requested listing" do
        Listing.stub(:find) { @listing }
        do_update
      end

      it "should update the requested listing" do
        Listing.stub(:find).with("1") { mock_listing }
	mock_listing.should_receive(:update_attributes).with({'title' => 'test', 'description' => 'test'})
        do_update
      end

      it "should assign @listing" do
        Listing.stub(:find) { mock_listing(:update_attributes => true) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "redirects to the updated listing" do
        do_update
        response.should redirect_to @listing
      end
    end

    context "with invalid params" do
    
      before (:each) do
        @listing.stub(:update_attributes).and_return(false)
      end

      def do_update
        put :update, :id => "1", :listing => {'title'=>'test', 'description' => 'test'}
      end

      it "should load the requested listing" do
        Listing.stub(:find) { @listing }
        do_update
      end

      it "should assign @listing" do
        Listing.stub(:find) { mock_listing(:update_attributes => false) }
        do_update
        assigns(:listing).should_not be_nil 
      end

      it "renders the edit form" do 
        Listing.stub(:find) { mock_listing(:update_attributes => false) }
        do_update
	response.should render_template(:edit)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before (:each) do
      Listing.stub!(:find).and_return(@listing)
    end

    context 'success' do

      it "should load the requested listing" do
        Listing.stub(:find).with("37").and_return(@listing)
      end

      it "destroys the requested listing" do
        Listing.stub(:find).with("37") { mock_listing }
        mock_listing.should_receive(:destroy)
        delete :destroy, :id => "37"
      end

      it "redirects to the listings list" do
        Listing.stub(:find) { mock_listing }
        delete :destroy, :id => "1"
        response.should be_redirect
      end
    end
  end

end