require 'spec_helper'
include ProcessMethod

describe Invoice do
  before :all do
    @user = create(:pixi_user, email: "jblow1234@pixitest.com") 
    @buyer = create(:pixi_user, first_name: 'Jaine', last_name: 'Smith', email: 'jaine.smith2@pixitest.com') 
    @listing = create(:listing, seller_id: @user.id)
    @account = @user.bank_accounts.create FactoryGirl.attributes_for :bank_account
  end
  before(:each) do
    @invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, status: 'unpaid')
    @details = @invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
  end

  subject { @invoice }

  describe 'attributes', base: true do
    let(:attr) { ProcessMethod::get_attr(@invoice, %w(id created_at updated_at)) }
    it_behaves_like "model attributes"
    it_behaves_like "model methods", %w(seller buyer transaction bank_account pixi_payments)
    it { is_expected.to belong_to(:buyer).with_foreign_key('buyer_id').class_name('User') }
    it { is_expected.to belong_to(:seller).with_foreign_key('seller_id').class_name('User') }
    it { is_expected.to have_many(:invoice_details) }
    it { is_expected.to have_many(:listings).through(:invoice_details) }
    it { is_expected.to accept_nested_attributes_for(:invoice_details).allow_destroy(true) }
    it { is_expected.to belong_to(:transaction) }
    it { is_expected.to belong_to(:bank_account) }
    it { is_expected.to have_many(:pixi_payments) }
    it { is_expected.to validate_presence_of(:buyer_id) }
    it { is_expected.to validate_presence_of(:seller_id) }
    it { is_expected.not_to allow_value('').for(:amount) }
    it { is_expected.not_to allow_value(0).for(:amount) }
    context 'amounts' do
      [['sales_tax', 15], ['ship_amt', 500], ['amount', 15000]].each do |item|
        it_behaves_like 'an amount', item[0], item[1]
      end
    end
  end

  describe 'must have pixis' do
    it 'has no pixis' do
      invoice = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, status: 'unpaid')
      expect(invoice).not_to be_valid
    end
    it { expect(@invoice).to be_valid }
  end

  describe "get_by_status" do 
    before { @invoice.save! }
    it "find specific invoices" do 
      expect(Invoice.count).to eq 1
      expect(Invoice.get_by_status('unpaid')).not_to be_empty 
    end
    it { expect(Invoice.get_by_status('paid')).to be_empty }
  end

  describe "get invoices by user" do 
    before :each, run: true do
      @invoice.save! 
    end

    context "get seller invoices" do 
      it "finds invoices", run: true do
        expect(Invoice.get_invoices(@user)).not_to be_empty 
      end
      it { expect(Invoice.get_invoices(@buyer)).to be_empty }
      it 'does not list invoice', run: true do
        @listing.status = 'removed'
        @listing.save!
        expect(Invoice.get_invoices(@user)).to be_empty 
      end
    end

    context "get_buyer_invoices" do 
      it { expect(Invoice.get_buyer_invoices(@user)).to be_empty }
      it 'lists invoice', run: true do
        expect(Invoice.get_buyer_invoices(@buyer)).not_to be_empty 
      end
      it 'does not list declined invoice' do
        @invoice.status = 'declined'
	@invoice.save!
        expect(Invoice.get_buyer_invoices(@buyer)).to be_empty 
      end
      it 'does not list invoice', run: true do
        @listing.status = 'removed'
        @listing.save!
        expect(Invoice.get_buyer_invoices(@buyer)).to be_empty 
      end
    end
  end

  describe "find_invoice" do 
    before { @invoice.save! }
    let(:order) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 75.0, "invoice_id"=> @invoice.id, "transaction_type"=>'invoice'} }
    let(:order1) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 75.0, "invoice_id"=> @invoice.id, "transaction_type"=>'pixi'} }
    let(:order2) { {"cnt"=> 1, "quantity1"=> 1, "item1"=> 'Pixi Post', "price1"=> 75.0, "invoice_id"=> ''} }

    it { expect(Invoice.find_invoice(order)).not_to be_nil }
    it { expect(Invoice.find_invoice(order1)).to be_nil }
    it { expect(Invoice.find_invoice(order2)).to be_nil }
  end

  describe "paid" do 
    it "should not verify invoice is paid" do 
      expect(@invoice.paid?).not_to be_truthy 
    end

    it "should verify invoice is paid" do 
      @invoice.status = 'paid'
      expect(@invoice.paid?).to be_truthy 
    end
  end

  describe "unpaid?" do 
    it "should verify invoice is unpaid" do 
      expect(@invoice.unpaid?).to be_truthy 
    end

    it "should not verify invoice is unpaid" do 
      @invoice.status = 'paid'
      expect(@invoice.unpaid?).not_to be_truthy 
    end
  end

  describe "has_shipping?" do 
    it "verifies invoice doesn't have shipping" do 
      expect(@invoice.has_shipping?).not_to be_truthy 
    end

    it "verifies invoice has_shipping" do 
      @invoice.ship_amt = 4.99
      expect(@invoice.has_shipping?).to be_truthy 
    end
  end

  describe "owner" do 
    it "should verify user is owner" do 
      expect(@invoice.owner?(@user)).to be_truthy 
    end

    it "should not verify user is owner" do 
      expect(@invoice.owner?(@buyer)).not_to be_truthy 
      expect(@invoice.owner?(nil)).not_to be_truthy 
    end
  end

  describe 'credit_account' do
    context 'credit_account w/ success' do
      before do
        allow_any_instance_of(Invoice).to receive(:credit_account).and_return(true)
      end
      it { expect(@invoice.credit_account).to be_truthy }
    end

    context 'credit_account w/ bad data' do
      before do
        allow_any_instance_of(Invoice).to receive(:credit_account).and_return(false)
      end
      it { expect(@invoice.credit_account).not_to be_truthy }
    end
  end

  describe 'get_conv_fee' do
    it "gets seller fee" do 
      expect(@invoice.get_conv_fee(@user)).to eq(CalcTotal::get_convenience_fee(@invoice.amount, @invoice.pixan_id).round(2))
    end

    it "gets buyer fee" do 
      expect(@invoice.get_conv_fee(@buyer)).to eq((CalcTotal::get_convenience_fee(@invoice.amount) + CalcTotal::get_processing_fee(@invoice.amount)).round(2))
    end

    it "return zero" do 
      @invoice.amount = nil
      expect(@invoice.get_conv_fee(@user)).to eq(0.0)
    end
  end

  describe 'get_fee' do
    before :each do
      @invoice.save!
    end

    it "gets seller fee" do 
      expect(@invoice.get_fee(true)).to eq(CalcTotal::get_convenience_fee(@invoice.amount, @invoice.pixan_id).round(2))
    end

    it "gets business seller fee" do 
      @user.update_attribute(:user_type_code, 'BUS')
      expect(@invoice.reload.get_fee(true)).to eq(CalcTotal::get_convenience_fee(@invoice.amount, nil, true).round(2))
    end

    it "gets seller pixi post fee" do 
      @pixan = create(:pixi_user)
      @listing.pixan_id = @pixan.id
      @listing.save
      expect(@invoice.get_fee(true)).to eq((@invoice.subtotal * PXB_TXN_PERCENT).round(2))
    end

    it "gets buyer fee" do 
      expect(@invoice.get_fee).to eq((CalcTotal::get_convenience_fee(@invoice.amount) + CalcTotal::get_processing_fee(@invoice.amount)).round(2))
    end

    it "return zero" do 
      @invoice.amount = nil
      expect(@invoice.get_fee).to eq(0.0)
    end
  end

  describe 'seller_amount' do
    before :each do
      @invoice.save!
    end

    it "gets seller amount" do 
      expect(@invoice.seller_amount).to eq(@invoice.amount - CalcTotal::get_convenience_fee(@invoice.amount).round(2))
    end

    it "gets business seller amount" do 
      @user.update_attribute(:user_type_code, 'BUS')
      expect(@invoice.reload.seller_amount).to eq(@invoice.amount - CalcTotal::get_convenience_fee(@invoice.amount, nil, true).round(2))
    end

    it "return zero" do 
      @invoice.amount = nil
      expect(@invoice.seller_amount).to eq(0.0)
    end
  end

  describe 'get_processing_fee' do
    it "should get fee" do 
      expect(@invoice.get_processing_fee).to be_truthy
    end

    it "should not get fee" do 
      @invoice.amount = nil
      expect(@invoice.get_processing_fee).to eq 0
    end
  end

  describe 'get_convenience_fee' do
    it "should get fee" do 
      expect(@invoice.get_convenience_fee).to be_truthy
    end

    it "should not get fee" do 
      @invoice.amount = nil
      expect(@invoice.get_processing_fee).to eq 0
    end
  end

  describe "transactions" do
    let(:transaction) { FactoryGirl.create :transaction }
    before :each, run: true do
      @invoice.update_attribute(:transaction_id, transaction.id)
    end

    context 'submit_payment' do
      it { expect(@invoice.submit_payment(nil)).not_to be_truthy }
      it { expect(@invoice.submit_payment(transaction.id)).to be_truthy }
    end

    context 'description' do
      it { expect(@invoice.description).to be_nil }
      it "shows txn description", run: true do
        expect(@invoice.description).to eq transaction.description
      end
    end

    context 'confirmation_no' do
      it { expect(@invoice.confirmation_no).to be_nil }
      it "shows txn confirmation_no", run: true do
        expect(@invoice.confirmation_no).to eq transaction.confirmation_no
      end
    end

    context 'transaction_amount' do
      it { expect(@invoice.transaction_amount).to eq 0.0 }
      it "shows txn amt", run: true do
        expect(@invoice.transaction_amount).to eq transaction.amt
      end
    end
  end

  describe "set_flds" do
    it "does set flds" do 
      invoice = build :invoice, seller_id: @user.id, buyer_id: @buyer.id, status: 'paid'
      details = invoice.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      invoice.save
      expect(invoice.status).not_to eq('unpaid')
    end

    it "does not set flds" do 
      @invoice.status = nil
      @invoice.save
      expect(@invoice.status).to eq('unpaid')
    end
  end

  describe "buyer" do 
    it { expect(@invoice.buyer_name).to eq(@buyer.name) } 
    it { expect(@invoice.buyer_first_name).to eq(@buyer.first_name) } 
    it { expect(@invoice.buyer_email).to eq(@buyer.email) } 

    it "should not find correct buyer name" do 
      @invoice.buyer_id = 100 
      expect(@invoice.buyer_first_name).to be_nil 
      expect(@invoice.buyer_name).to be_nil 
    end

    it "should not find correct buyer email" do 
      @invoice.buyer_id = 100 
      expect(@invoice.buyer_email).to be_nil 
    end
  end

  describe "seller" do 
    it { expect(@invoice.seller_name).to eq(@user.name) } 
    it { expect(@invoice.seller_first_name).to eq(@user.first_name) } 
    it { expect(@invoice.seller_email).to eq(@user.email) } 

    it "should not find correct seller name" do 
      @invoice.seller_id = 100 
      expect(@invoice.seller_first_name).to be_nil 
      expect(@invoice.seller_name).to be_nil 
    end

    it "should not find correct seller email" do 
      @invoice.seller_id = 100 
      expect(@invoice.seller_email).to be_nil 
    end
  end

  describe "pixi methods" do 
    before :each, run: true do
      @invoice.save!
    end

    context 'pixi_title' do
      it "has a title", run: true do
        expect(@invoice.pixi_title).not_to be_empty  
      end

      it "should not find correct pixi_title" do 
        @invoice.pixi_id = '100' 
        expect(@invoice.pixi_title).to be_nil 
      end
    end
    context 'pixan_id' do
      it { expect(@invoice.pixan_id).to be_nil } 

      it "finds pixan_id", run: true do
        @listing.pixan_id = 100 
        @listing.save
        expect(@invoice.pixan_id).to eq(100)
      end
    end

    context "short_title" do 
      it "has a short title", run: true do
        expect(@invoice.short_title).not_to be_empty  
      end
      it "should not find correct short_title" do 
        @invoice.pixi_id = '100' 
        expect(@invoice.short_title).to be_nil 
      end
    end
    context "pixi_post" do 
      it { expect(@invoice.pixi_post?).not_to be_truthy }

      it 'has a pixi post', run: true do 
        @pixan = FactoryGirl.create(:contact_user) 
        @listing.pixan_id = @pixan.id 
        @listing.save
        expect(@invoice.pixi_post?).to be_truthy 
      end
    end
  end

  describe "nice status" do 
    it "should return a nice status" do 
      expect(@invoice.nice_status).to be_truthy 
    end

    it "should not return a nice status" do 
      @invoice.status = nil
      expect(@invoice.nice_status).not_to be_truthy 
    end
  end
  
  describe "load invoice" do
    def check_inv flg=false, fulfillment_type_code=nil
      fulfillment_type_code ||= @listing.fulfillment_type_code 
      inv = Invoice.load_new(@user.reload, @buyer.id, @listing.pixi_id, fulfillment_type_code) 
      expect(inv).not_to be_nil
      expect(inv.buyer_id).to eq @buyer.id
      expect(inv.amount).to eq @listing.price unless flg
      expect(inv.invoice_details.first.quantity).to eq @pixi_want.quantity if flg
      expect(inv.invoice_details.first.fulfillment_type_code).to eq @listing.fulfillment_type_code
      expect(inv.ship_amt).not_to be_nil
      expect(inv.invoice_details.first.fulfillment_type_code).to eq @listing.fulfillment_type_code 
      if FulfillmentType.ship_codes.include?(fulfillment_type_code)
        expect(inv.ship_amt).not_to be_nil
      else
        expect(inv.ship_amt).to eq 0.0
      end
      expect(/^\d+??(?:\.\d{0,2})?$/.match(inv.invoice_details.first.subtotal.to_s)).not_to be_nil
    end

    it "loads new invoice" do
      check_inv
    end

    it 'sets pixi_id when multiple pixis exist' do
      listing = FactoryGirl.create(:listing, title: 'Leather Chair', seller_id: @user.id)
      check_inv
    end

    it 'sets quantity when same buyer wants pixi' do
      @listing.update_attribute(:quantity, 4)
      @pixi_want = @buyer.pixi_wants.create attributes_for :pixi_want, pixi_id: @listing.pixi_id, quantity: 2
      check_inv true
    end

    it "does not load ship_amt for non-shipping fulfillment_type_code" do
      @listing.update_attribute(:fulfillment_type_code, 'P')
      check_inv false, 'P'
    end

    it 'loads free pixi' do
      @listing.update_attribute(:price, nil)
      check_inv 
    end

    it "loads new invoice w/o pixi_id & buyer_id" do
      inv = Invoice.load_new(@user, nil, nil)
      expect(inv).not_to be_nil
    end    

    it "does not load new invoice" do
      expect(Invoice.load_new(nil, nil, nil)).to be_nil
    end
  end

  describe 'format_date' do
    let(:transaction) { FactoryGirl.create :transaction }
    before :each, run: true do
      @invoice.save!
    end

    it "show current updated date", run: true do
      expect(@invoice.format_date(@invoice.updated_at)).not_to eq @invoice.updated_at.strftime('%m/%d/%Y %l:%M %p')
    end

    it "shows local updated date" do
      @invoice.transaction_id = transaction.id
      @invoice.save!
      expect(@invoice.format_date(@invoice.updated_at)).to eq Time.now.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  describe 'load_details' do
    before :each, run: true do
      @invoice.save!
    end
    it 'load nothing' do
      Invoice.load_details
      expect(InvoiceDetail.count).to eq 0
    end
    it 'loads details', run: true do
      Invoice.load_details
      expect(InvoiceDetail.count).not_to eq 0
    end
  end

  describe 'mark_as_closed' do
    before(:each) do
      @other_buyer = create :pixi_user
      @invoice.save!; sleep 2
      @invoice2 = @user.invoices.build attributes_for(:invoice, buyer_id: @buyer.id, status: 'unpaid')
      @details2 = @invoice2.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice2.save!; sleep 2
      @invoice3 = @user.invoices.build attributes_for(:invoice, buyer_id: @other_buyer.id, status: 'paid')
      @details3 = @invoice3.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @invoice3.save!; sleep 2
    end

    it 'closes other invoices' do
      @invoice.status = 'paid'
      @invoice.save!; sleep 3
      expect(Invoice.where(status: 'closed').count).to eq 1
    end

    it 'does not close other invoices' do
      sleep 3
      @invoice.amount = 200.00
      @invoice.save!
      expect(@invoice3.status).not_to eq 'closed'
    end

    it 'closes not all other invoices' do
      listing = create(:listing, seller_id: @user.id, title: 'Sofa')
      @invoice3 = @user.invoices.build attributes_for(:invoice, buyer_id: @other_buyer.id, status: 'unpaid')
      @details3 = @invoice3.invoice_details.build attributes_for :invoice_detail, pixi_id: @listing.pixi_id 
      @details4 = @invoice3.invoice_details.build attributes_for :invoice_detail, pixi_id: listing.pixi_id 
      @invoice3.save!
      @invoice.update_attribute(:status, 'paid'); sleep 2
      expect(@invoice3.status).not_to eq 'closed'
      expect(@invoice.status).to eq 'paid'
      expect(Invoice.where(status: 'closed').count).to eq 1
    end
  end

  describe "unpaid_old_invoices" do
    it "toggles number_of_days" do
      @invoice.created_at = 3.days.ago
      @invoice.save!
      expect(Invoice.unpaid_old_invoices).to include @invoice
      expect(Invoice.unpaid_old_invoices(5)).not_to include @invoice
    end

    it "does not return invoices less than two days old" do
      expect(Invoice.unpaid_old_invoices).not_to include @invoice
    end

    it "does not return paid invoices" do
      @invoice.status = "paid"
      @invoice.save!
      expect(Invoice.unpaid_old_invoices).not_to include @invoice
    end
  end  

  describe "decline" do
    it "assigns status and decline reason" do
      @invoice.decline "No Longer Interested"
      expect(@invoice.status).to eq "declined"
      expect(@invoice.decline_reason).to eq "No Longer Interested"
    end
  end

  describe "get_pixi amt left" do
    before :each do
      @invoice.save!; sleep 2
    end
    it { expect(@invoice.get_pixi_amt_left(@listing.pixi_id)).to eq 1 }
    it "has count > 1" do
      @listing.update_attribute(:quantity, 3)
      @new_inv = @user.invoices.build FactoryGirl.attributes_for(:invoice, buyer_id: @buyer.id, status: 'paid')
      @inv_det = @new_inv.invoice_details.build FactoryGirl.attributes_for :invoice_detail, pixi_id: @listing.pixi_id, quantity: 1
      @new_inv.save!
      expect(@listing.reload.amt_left).to eq 2
      expect(@invoice.get_pixi_amt_left(@listing.pixi_id)).to eq 2
    end
  end

  describe 'bank_account' do
    before :each, run: true do
      @invoice.bank_account_id = @account.id
    end
    context 'acct_no' do
      it { expect(@invoice.acct_no).not_to eq @account.acct_no }
      it 'has acct_no', run: true do
        expect(@invoice.acct_no).to eq @account.acct_no
      end
    end

    context 'bank_name' do
      it { expect(@invoice.bank_name).to be_nil }
      it 'has bank_name', run: true do
        expect(@invoice.bank_name).to eq @account.bank_name
      end
    end
  end

  describe 'get_by_keys' do
    before :each do
      @invoice.save! 
    end
    context 'get_by_buyer' do
      it { expect(Invoice.get_by_buyer(@buyer.id)).to include @invoice }
      it { expect(Invoice.get_by_buyer(@user.id)).not_to include @invoice }
    end
    context 'get_by_seller' do
      it { expect(Invoice.get_by_seller(@buyer.id)).not_to include @invoice }
      it { expect(Invoice.get_by_seller(@user.id)).to include @invoice }
    end
    context 'get_by_pixi' do
      it { expect(Invoice.get_by_pixi('1234')).not_to include @invoice }
      it { expect(Invoice.get_by_pixi(@listing.pixi_id)).to include @invoice }
    end
    context 'get_by_status_and_pixi' do
      it { expect(Invoice.get_by_status_and_pixi('unpaid', @buyer.id, '1234')).not_to include @invoice }
      it { expect(Invoice.get_by_status_and_pixi('unpaid', @user.id, @listing.pixi_id)).not_to include @invoice }
      it { expect(Invoice.get_by_status_and_pixi('unpaid', @buyer.id, @listing.pixi_id, false)).not_to include @invoice }
      it { expect(Invoice.get_by_status_and_pixi('paid', @buyer.id, @listing.pixi_id)).not_to include @invoice }
      it { expect(Invoice.get_by_status_and_pixi('unpaid', @buyer.id, @listing.pixi_id)).to include @invoice }
      it { expect(Invoice.get_by_status_and_pixi('unpaid', @user.id, @listing.pixi_id, false)).to include @invoice }
      it 'successfully handles paid invoices' do
        @invoice.update_attribute(:status, 'paid')
        expect(Invoice.get_by_status_and_pixi('paid', @user.id, '1234', false)).not_to include @invoice 
        expect(Invoice.get_by_status_and_pixi('paid', @user.id, @listing.pixi_id)).not_to include @invoice 
        expect(Invoice.get_by_status_and_pixi('unpaid', @user.id, @listing.pixi_id, false)).not_to include @invoice 
        expect(Invoice.get_by_status_and_pixi('paid', @buyer.id, @listing.pixi_id, false)).not_to include @invoice 
        expect(Invoice.get_by_status_and_pixi('paid', @buyer.id, @listing.pixi_id)).to include @invoice 
        expect(Invoice.get_by_status_and_pixi('paid', @user.id, @listing.pixi_id, false)).to include @invoice 
      end
    end
  end

  describe 'process_invoice' do
    before :all do
      @listing.user.active_listings_count = 1
      @buyer.pixi_wants.create attributes_for :pixi_want, pixi_id: @listing.pixi_id
    end

    it 'assigns attributes' do
      order = Invoice.process_invoice(@listing, @buyer.id, 'P')
      keys = %w(id1 item1 title seller promo_code cnt qtyCnt quantity1 price1
                transaction_type invoice_id tax_total inv_total user_id)
      expect(keys).to eq order.keys
    end

    it 'assigns ship_amt if SHP or SD is passed as fulfillment type code' do
      order = Invoice.process_invoice(@listing, @buyer.id, 'SHP')
      expect(order.keys).to include 'ship_amt'
      expect(order['invoice_id']).not_to be_blank
    end

    it 'does not send email' do
      expect {
        Invoice.process_invoice(@listing, @buyer.id, 'P')
      }.not_to change {
        Delayed::Job.count
      }
    end
  end
end
