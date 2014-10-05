require 'spec_helper'

describe Picture do
  before(:each) do
    filename = "#{Rails.root}/spec/fixtures/photo.jpg"
    filename2 = "#{Rails.root}/spec/fixtures/photo2.png"

    @file = Rack::Test::UploadedFile.new(filename, "image/jpg")
    @bigfile = Rack::Test::UploadedFile.new(filename2, "image/png")

    @listing = FactoryGirl.create(:listing)
    @site = FactoryGirl.create(:site)

    @bigpic = @listing.pictures.build
    @picture = @listing.pictures.build
    @site_picture = @site.pictures.build
    @picture.photo, @bigpic.photo, @site_picture.photo  = @file, @bigfile, @file
  end

  subject { @picture } 

  it { should respond_to(:photo) }
  it { should respond_to(:processing) }
  it { should respond_to(:photo_file_name) }
  it { should respond_to(:photo_file_path) }
  it { should respond_to(:photo_content_type) }
  it { should respond_to(:photo_file_size) }
  it { should respond_to(:photo_updated_at) }
  it { should respond_to(:set_default_url) }
  it { should respond_to(:direct_upload_url) }

  it { should respond_to(:imageable) }
  it { should have_attached_file(:photo) }
  it { should validate_attachment_content_type(:photo).
                      allowing('image/png', 'image/gif', 'image/jpg', 'image/jpeg', 'image/bmp', 'image/tiff').
                      rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:photo).less_than(5.megabytes) }

  describe "listing photo validations" do
    it "big pic should not be valid" do
      @bigpic.should_not be_valid
    end

    it "should be valid" do
      @picture.should be_valid
    end

    it "should create a new instance given valid attributes" do
      @picture.save!
    end
  end

  context "check listing photo attributes" do
    before(:each) do
      @picture.save!
    end

    it "should receive photo_file_name from :photo" do 
      @picture.photo_file_name.should_not be_empty
    end
  end

  describe "site photo validations" do
    it "should be valid" do
      @site_picture.should be_valid
    end

    it "should create a new instance given valid attributes" do
      @site_picture.save!
    end
  end

  context "check site photo attributes" do
    before(:each) do
      @site_picture.save!
    end

    it "should receive photo_file_name from :photo" do 
      @site_picture.photo_file_name.should_not be_empty
    end
  end

  describe "regenerate_styles" do
    it { @picture.should respond_to :regenerate_styles }
  end

  describe 'picture from url' do
    it 'does not return picture url' do
      expect(@picture.picture_from_url).to be_nil
    end

    it 'returns a picture url' do
      @picture.direct_upload_url = "http://pixiboard.com"
      expect(@picture.picture_from_url).not_to be_nil
    end
  end

  describe 'set file url' do
    it 'does not return set_file_url' do
      expect(@picture.set_file_url(nil)).to be_nil
    end

    it 'returns a set_file_url' do
      url = "photos/000/002/036/original/photo.jpg"
      expect(@picture.set_file_url(url)).not_to be_nil
    end
  end

  describe 'transliterate file name' do

    it 'should transliterate the filename' do
      pic = Picture.new
      pic.photo = File.new(Rails.root.join('spec', 'fixtures', %Q{bad file name.png}))
      expect('bad_file_name.png').to eq pic.photo_file_name
    end

    it 'transliterates from file url name' do
      @picture.direct_upload_url = "photos/000/002/036/original/2014-07-25 15.46.36.jpg"
      expect(@picture.set_file_url(@picture.direct_upload_url)).to eq "photos/000/002/036/original/2014-07-25_15_46_36.jpg"
    end
  end

end
