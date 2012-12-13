## Mollie iDeal [![Build Status](https://secure.travis-ci.org/jhnvz/mollie_ideal.png?branch=master)](http://travis-ci.org/jhnvz/mollie_ideal)

Wrapper for the mollie ideal api

Installation
------------

1. Add `gem 'mollie_ideal'` to your Gemfile.
1. Run `bundle install`.

## Usage
```ruby
# for production
client = MollieIdeal::Client.new(:partner_id => your_partner_id)

# testmode
client = MollieIdeal::Client.new(:testmode => true, :partner_id => your_partner_id)

# Example of how to get the banklist and populate a selectbox
@banks = client.banklist
= select_tag :issuerid, options_for_select(@banks)

# How to setup a payment
response = client.setup_payment(
  :amount      => (amount_in_cents).to_i,
  :bank_id     => params[:bank_id],
  :returnurl   => "http://#{request.env['HTTP_HOST']}/ideal/return",
  :reporturl   => "http://#{request.env['HTTP_HOST']}/ideal/report",
  :description => 'your description'
)
oder.update_attributes(:transaction_id => response.transaction_id)
redirect_to response.URL

# How to handle report on the report url
# For safety reasons mollie calls a report url for updating payment status before redirecting back to the application
order = Order.find_by_transaction_id(params[:transaction_id])
response = client.check_payment(order.transaction_id)
order.update_attributes(:payed => response.payed)

# When mollie redirects the user back you can check if the payment was succesfull bij finding the order object
@order = Order.find_by_transaction_id(params[:transaction_id])
```
## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Johan van Zonneveld. See LICENSE for details.