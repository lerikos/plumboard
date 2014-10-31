% if mode == 'definition':
Balanced::BadRequest

% else:
require 'balanced'
Balanced.configure('8af725c6d54611e2bf5e026ba7f8ec28')

bank_account = Balanced::BankAccount.new( :uri => '/v1/marketplaces/TEST-MP4erLnXCYoaeyr3tx95WSKc/bank_accounts', :account_number => '9900000001',:name => 'Johann Bernoulli',:routing_number => '100000007',:type => 'checking')

begin
  bank_account.save
rescue Balanced::BadRequest => ex
  raise "Key is not returned!" unless ex.extras.has_key? "routing_number"
end

% endif
