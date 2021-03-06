require 'spec_helper'

describe PixiPostDetail do
  before(:all) do
    @user = create(:pixi_user)
    @listing = create(:listing, seller_id: @user.id)
    @pixan = create :pixi_user 
    @post = @user.pixi_posts.create attributes_for :pixi_post, pixan_id: @pixan.id, appt_date: Time.now+3.days, 
        completed_date: Time.now+3.days, pixi_id: @listing.pixi_id, appt_time: Time.now+3.days
  end
  before(:each) do
    @details = @post.pixi_post_details.build pixi_id: @listing.pixi_id 
  end

  subject { @details }

  it { is_expected.to belong_to(:pixi_post) }
  it { is_expected.to belong_to(:listing).with_foreign_key('pixi_id') }
  it { is_expected.to validate_presence_of(:pixi_id) }
  it { is_expected.to respond_to(:pixi_post_id) }
  it { is_expected.to respond_to(:pixi_id) }

  describe 'pixi_title' do
    it "has a title", run: true do
      expect(@details.pixi_title).not_to be_empty  
    end

    it "should not find correct pixi_title" do 
      @details.pixi_id = '100' 
      expect(@details.pixi_title).to be_nil 
    end
  end
end
