<%= boiler_plate %>
marketplace = Balanced::Marketplace.my_marketplace

bank_account_info = {
<%= params_to_hash.call(request['bank_account']).indent(2) %>
}

credit = Balanced::Credit.new(
  :amount => <%= request['amount'] %>,
  :bank_account => bank_account_info
).save
