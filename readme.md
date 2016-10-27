[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)  
[![Slack Status](https://opensuite-slackin.herokuapp.com/badge.svg)](http://opensuite-slackin.herokuapp.com)  

# Allow Customers to Pay NetSuite Invoices with Stripe

![Example](http://g.recordit.co/gzY1JCsE5w.gif)

## Help?

[Join the OpenSuite chat room](http://opensuite-slackin.herokuapp.com/)

## Getting Started

1. Deploy app to heroku
2. [Find open invoice](https://system.na1.netsuite.com/app/accounting/transactions/transactionlist.nl?searchtype=Transaction&searchid=-2100&Transaction_TYPE=CustInvc
)
3. Copy internal ID of NetSuite Invoice

[SuiteSync](http://SuiteSync.io) can also host a more advanced version of this form for you.

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
