require 'spec_helper'
require 'will_paginate'

feature "Conversations" do
  subject { page }

  before(:each) do
    @user = create :pixi_user
    login_as(@user, :scope => :user, :run_callbacks => false)
    @sender = create :pixi_user, first_name: 'Tom', last_name: 'Davis', email: 'tdavis@pixitest.com'
    @listing = create :listing, seller_id: @user.id
  end

  def add_invoice status='unpaid'
    @seller = create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @listing1 = create :listing, seller_id: @seller.id
    @invoice = @seller.invoices.build attributes_for(:invoice, buyer_id: @user.id, status: status)
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing1.pixi_id 
    @invoice.save!
  end

  def sent_invoice status='unpaid'
    @buyer = create(:pixi_user, first_name: 'Kim', last_name: 'Harris', email: 'kimmy@pixitest.com')
    @invoice = @user.invoices.create attributes_for(:invoice, buyer_id: @buyer.id, status: status)
    @details = @invoice.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
    @invoice.save!
  end
   
  def add_post conv
    @post_reply = conv.posts.create attributes_for :post, user_id: @user.id, recipient_id: @sender.id, pixi_id: @listing.pixi_id
  end

  def add_conversation
    @conversation = @listing.conversations.create attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
    @post = @conversation.posts.create attributes_for :post, user_id: @sender.id, recipient_id: @user.id, pixi_id: @listing.pixi_id
  end

  def add_system_conversation
    @support = create(:pixi_user, first_name: 'Pixiboard', last_name: 'Support', email: 'support@pixiboard.com')
    @conversation = @listing.conversations.create attributes_for :conversation, user_id: @support.id, recipient_id: @user.id
    @post = @conversation.posts.create attributes_for :post, user_id: @support.id, recipient_id: @user.id, pixi_id: @listing.pixi_id, 
      msg_type: 'system'
  end

  def send_reply
    expect{
      fill_in 'reply_content', with: "I'm interested in this pixi. Please contact me." 
      click_send
    }.to change(Post,:count).by(1)
  end

  def click_send
    click_on 'Send'
    sleep 3
  end

  describe 'Received conversations w no conversations' do
    before :each do
      visit listings_path 
      click_on 'notice-btn'
    end

    it 'shows content' do
      @conversation = @listing.conversations.create attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
      expect(page).to have_link('Sent', href: conversations_path(status: 'sent'))
      expect(page).to have_link('Received', href: conversations_path(status: 'received'))
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path)
      expect(page).to have_content 'No conversations found.'
      expect(page).not_to have_selector('#conv-trash-btn') 
      expect(page).not_to have_selector('#conv-pay-btn') 
      expect(page).not_to have_button('Reply')
    end
  end

  describe 'Received conversations' do
    before :each do
      add_conversation
      visit listings_path 
      click_on 'notice-btn'
    end

    it 'shows content' do
      #page.should have_selector('title', :text => full_title('Messages'))
      expect(page).to have_content @conversation.user.name
      expect(page).to have_link('Sent', href: conversations_path(status: 'sent'))
      expect(page).to have_link('Received', href: conversations_path(status: 'received'))
      expect(page).to have_link('Mark All Read', href: mark_posts_path)
      expect(page).to have_selector('#conv-trash-btn') 
      expect(page).to have_selector('#conv-bill-btn') 
      expect(page).not_to have_selector('#conv-pay-btn') 
      expect(page).to have_selector('#conv-show-btn') 
    end

    it "marks all posts read", js: true do
      sleep 3
      expect(page).to have_link('Mark All Read', href: mark_posts_path)
      click_on 'Mark All Read'
      expect(page).to have_css('li.active a') 
    end
     
    describe 'show messages' do
      before :each do
        visit conversations_path(status: 'received')
      end

      it "opens messages page" do
        expect(page).to have_selector('#conv-show-btn') 
        page.find('#conv-show-btn').click
        expect(page).to have_content @conversation.pixi_title
      end
    end

    describe 'open billable invoice' do
      before :each do
        @user.bank_accounts.create FactoryGirl.attributes_for :bank_account, status: 'active'
        visit conversations_path(status: 'received')
      end

      it "opens create invoice page", js: true do
        expect(page).to have_selector('#conv-bill-btn') 
        page.find('#conv-bill-btn').click
	sleep 3
	  expect { 
            fill_in 'inv_price1', with: "100"
            select("4", :from => 'inv_qty1')
	    click_link 'OK'
	    click_button 'Send'; sleep 3
	  }.to change(Invoice, :count).by(1)
	  expect(page).to have_content "$400.00" 
      end
    end
     
    describe 'pay invoice' do
      before :each do
        add_invoice
        visit conversations_path(status: 'received')
      end

      it "opens pay invoice page" do
        expect(page).to have_selector('#conv-pay-btn') 
        page.find('#conv-pay-btn').click
        expect(page).to have_content 'Amount Due'
      end
    end
     
    describe 'paid invoice' do
      before :each do
        add_invoice 'paid'
        visit conversations_path(status: 'received')
      end

      it { is_expected.not_to have_selector('#conv-pay-btn') }
    end
     
    describe 'paid invoice after opening messages' do
      before :each do
        add_invoice
        visit conversations_path(status: 'received')
        sleep 5;
      end

      it "opens pay invoice page" do
        expect(page).to have_selector('#conv-pay-btn') 
	@invoice.status = 'paid'; @invoice.save
	sleep 3;
        page.find('#conv-pay-btn').click
        expect(page).to have_content 'Amount Due'
        expect(page).not_to have_content 'Unpaid'
      end
    end
     
    describe 'paid invoice' do
      before :each do
        add_invoice 'paid'
        visit conversations_path
      end

      it { is_expected.not_to have_selector('#conv-pay-btn') }
    end
  end
     
  describe 'Received conversations - ajax', js: true do
    before :each do
      add_conversation
      add_invoice
      visit conversations_path(status: 'received')
      click_on 'Sent'
      click_on 'Received'
      sleep 5
    end
    
    it 'shows content' do
      expect(page).to have_link('Mark All Read', href: mark_posts_path)
      expect(page).to have_content @conversation.user.name
      expect(page).to have_content @conversation.listing.title
      expect(page).to have_content @post.content
      expect(page).to have_selector('#conv-trash-btn') 
      expect(page).to have_selector('#conv-pay-btn') 
      expect(page).not_to have_content 'No conversations found' 
    end

    it "pays an invoice" do
      expect(page).to have_selector('#conv-pay-btn') 
      page.find('#conv-pay-btn').click
      expect(page).to have_content 'Amount Due'
    end

  end
     
  describe 'No sent conversations' do
    before :each do 
      visit conversations_path(status: 'received')
    end

    it 'shows no sent conversations', js: true do
      click_on 'Sent'
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path) 
      expect(page).to have_content 'No conversations found' 
    end
  end
     
  describe 'sent conversations' do
    before :each do 
      @reply_listing = create :listing, seller_id: @sender.id
      @reply_conv= @reply_listing.conversations.create attributes_for :conversation, user_id: @user.id, recipient_id: @sender.id
      @reply_post = @reply_conv.posts.create attributes_for :post, user_id: @user.id, recipient_id: @sender.id, pixi_id: @listing.pixi_id
      visit conversations_path(status: 'received')
    end

    it 'shows sent conversations', js: true do
      click_on 'Sent'
      expect(page).not_to have_link('Mark All Read', href: mark_posts_path) 
      expect(page).to have_content @reply_conv.recipient.name 
      expect(page).to have_content @reply_conv.listing.title 
      expect(page).to have_content @reply_post.content 
      expect(page).not_to have_content 'No conversations found' 
    end
  end

  describe 'Show Page', js: true do
    before :each do
      add_conversation
      visit conversations_path(status: 'received')
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
    end
    
    it 'shows content' do
      expect(page).to have_content @conversation.user.name
      expect(page).to have_content @conversation.listing.title
      expect(page).to have_content @post.content
    end

    it "can go back to received page" do
      click_on 'Received'
      sleep 5
      expect(page).to have_selector('#conv-show-btn') 
    end

    it "can go back to sent page" do
      click_on 'Sent'
      expect(page).to have_content 'No conversations found' 
    end

    it 'removes last message' do
      expect(Post.count).to eq 1
      expect(page).to have_selector('.msg-trash-btn') 
      page.find(".msg-trash-btn", :visible => true).click
      accept_btn
      sleep 5
      expect(Post.where(recipient_status: 'removed').count).to eq 1
      expect(page).to have_content 'No conversations found' 
    end

    it 'removes a message' do
      add_post @conversation; sleep 2
      expect(Post.all.count).to eq 2
      expect(page).to have_selector('.msg-trash-btn') 
      page.find(".msg-trash-btn", :visible => true).click
      accept_btn
      sleep 5
      expect(page).not_to have_content 'No conversations found' 
      expect(page).to have_selector('.msg-trash-btn') 
      expect(Post.where(recipient_status: 'active').count).to eq 1
      expect(Post.where(recipient_status: 'removed').count).to eq 1
    end

    context 'replying' do 
      it 'replies to a conversation' do 
        send_reply
      end

      it 'does not reply when new message invalid' do
        expect{
            fill_in 'reply_content', with: nil
            click_send
        }.not_to change(Post,:count)
        expect(page).to have_content @conversation.listing.title
      end
    end
  end

  describe 'Seller Invoiced Pixis', js: true do
    before :each do
      add_conversation
      @user.bank_accounts.create attributes_for :bank_account, status: 'active'
      sent_invoice; sleep 2;
      visit conversations_path(status: 'received')
      sleep 5
    end

    it 'hides bill button' do
      page.find("#conv-bill-btn", :visible => false)
    end
  end

  describe 'Seller Pixis', js: true do
    before :each do
      add_conversation
      @user.bank_accounts.create attributes_for :bank_account, status: 'active'
      visit conversations_path(status: 'received')
      sleep 5
    end

    it 'opens new invoice' do
      expect(page).to have_selector('#conv-bill-btn') 
      sleep 2;
      page.find("#conv-bill-btn", :visible => true).click
      expect(page).to have_content 'Sales Tax'
    end

    it 'handles removed pixi' do
      expect(page).to have_selector('#conv-bill-btn') 
      @listing.status = 'removed'; @listing.save
      sleep 2;
      page.find("#conv-bill-btn", :visible => true).click
      expect(page).not_to have_selector('#pay-btn') 
    end

    it 'handles sold pixi' do
      expect(page).to have_selector('#conv-bill-btn') 
      @listing.status = 'sold'; @listing.save
      sleep 2;
      page.find("#conv-bill-btn", :visible => true).click
      sleep 2;
      expect(page).to have_content NO_INV_PIXI_MSG
    end
  end

  describe 'Remove Sent Conversation', js: true do
    before :each do
      visit destroy_user_session_path
      sleep 1;
      init_setup @sender
      add_conversation
      visit conversations_path(status: 'sent')
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
    end
    
    it 'shows content' do
      sleep 2;
      expect(page).to have_content @conversation.pixi_title
      expect(page).to have_content @post.content
    end

    it 'removes conversation' do
      page.find("#conv-trash-btn", :visible => true).click
      accept_btn
      sleep 3
      expect(page).to have_content 'No conversations found' 
      expect(Conversation.where(status: 'removed').count).to eq 1
    end
  end

  describe 'Show System Messages', js: true do
    before :each do
      add_system_conversation
      visit conversations_path(status: 'received')
    end
    
    it 'shows conversation content' do
      expect(page).to have_selector('#conv-show-btn') 
      expect(page).to have_selector('#conv-trash-btn') 
      expect(page).not_to have_selector('#conv-pay-btn') 
      expect(page).not_to have_selector('#conv-bill-btn') 
    end
    
    it 'shows message content' do
      sleep 5
      page.find("#conv-show-btn", :visible => true).click
      expect(page).to have_selector('#conv-trash-btn') 
      expect(page).not_to have_selector('#conv-pay-btn') 
      expect(page).not_to have_selector('#conv-bill-btn') 
      expect(page).to have_content @conversation.user.name
      expect(page).to have_content @conversation.listing.title
      expect(page).to have_content @post.content
    end

    it 'removes conversation' do
      page.find("#conv-trash-btn", :visible => true).click
      accept_btn
      sleep 5
      expect(Conversation.where(recipient_status: 'removed').count).to eq 1
      expect(page).to have_content 'No conversations found' 
    end
  end

  describe 'pagination', js: true do
    before(:each) do 
      5.times { 
        @user = create :pixi_user
        @sender = create :pixi_user
        @listing = create :listing, seller_id: @user.id
        @listing.conversations.create attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id 
        @conversation = @listing.conversations.create attributes_for :conversation, user_id: @sender.id, recipient_id: @user.id
        @post = @conversation.posts.create attributes_for :post, user_id: @sender.id, recipient_id: @user.id, pixi_id: @listing.pixi_id 
      }
      visit conversations_path(status: 'received')
    end

    let(:first_page)  { Conversation.paginate(page: 1) }
    let(:second_page)  { Conversation.paginate(page: 2) }

    it { is_expected.to have_selector('div', class: 'pagination') }

    it 'lists each conversation' do
      first_page.each do |conv|
        expect(page).to have_selector('li', :value => conv.id)
      end
    end

    it 'does not list second page for conversation' do
      second_page.each do |conv|
        expect(page).not_to have_selector('li', :value => conv.id)
      end
    end

  end
end
