[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)  
[![Slack Status](https://opensuite-slackin.herokuapp.com/badge.svg)](http://opensuite-slackin.herokuapp.com)  

# Allow Customers to Pay NetSuite Invoices with Stripe

This simple sinatra application enables customers to pay off their open NetSuite invoices using ACH or credit card.

Here's a [demo video](http://recordit.co/gzY1JCsE5w) along with [written documentation](https://dashboard.suitesync.io/docs/b2b-payments) about this feature.

There is more robust version of this application that is hosted and managed as part of the SuiteSync product. This open source implementation is designed for organizations that would like to customize their collection process beyond what the hosted version allows.

## Help?

[Join the OpenSuite chat room](http://opensuite-slackin.herokuapp.com/) or contact us at support@suitesync.io.

## Development

```
copy .env-example .env
# edit .env with NetSuite and Stripe credentials

bundle
bundle exec ruby pay.rb
```

## Getting Started

1. Deploy app to heroku
2. [Find open invoice](https://system.na1.netsuite.com/app/accounting/transactions/transactionlist.nl?searchtype=Transaction&searchid=-2100&Transaction_TYPE=CustInvc
)
3. Copy internal ID of NetSuite Invoice to the payment URL, or visit http://127.0.0.1:4567/example to pick a random invoice from your NetSuite account

[SuiteSync](http://SuiteSync.io) can also host a more advanced version of this form for you.

## Testing

**Credit or Debit Card**  
Card number: 4242 42424 4242 4242  
CCV: 123  
Expiration 12/2020  

**ACH Payment**  
Bank to use: PNC  
Username: plaid_test  
Password: plaid_good  
Security question: tomato  

**Manual ACH Payment**  
Routing: 110000000  
Account: 000123456789  
Verification: 32, 45

## Description

## Setting up a Link on the NetSuite Invoice

1. Customization > Lists, Records, and Fields > Transaction Body Fields > New
2. Configure field:
  * Label: `Stripe Invoice Payment Link`
  * ID: `_stripe_invoice_payment_link`
  * Type: `Hyperlink`
  * Display > Subtab: `Main`
  * Validation & Defaulting > Default Value: `https://netsuite-invoice-stripe.herokuapp.com/{id}`
  * Validation & Defaulting > Formula: unchecked. After save, make sure this value is still unchecked. NetSuite will reset this field value for you without warning.
  * Applies To: `Sale`
  * Store value: `false` / unchecked
