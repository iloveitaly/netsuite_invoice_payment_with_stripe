require 'dotenv'
Dotenv.load

require 'sinatra'
require "sinatra/reloader" if development?

require 'stripe'
require 'netsuite'

require 'pry'

Stripe.api_key = ENV['STRIPE_KEY']

NetSuite.configure do
  reset!

  # NOTE that API versions > 2015_1 require a more complicated authentication setup
  api_version '2015_1'
  read_timeout 60 * 3
  silent ENV['NETSUITE_SILENT'].nil? || ENV['NETSUITE_SILENT'] == 'true'

  email ENV['NETSUITE_EMAIL']
  password ENV['NETSUITE_PASSWORD']
  account ENV['NETSUITE_ACCOUNT']

  wsdl_domain 'webservices.na1.netsuite.com'

  soap_header({
    'platformMsgs:preferences' => {
      'platformMsgs:ignoreReadOnlyFields' => true,
    }
  })
end

get '/' do
  redirect "https://github.com/iloveitaly/netsuite_invoice_payment_with_stripe"
end

get '/:invoice_id' do
  ns_invoice = NetSuite::Utilities.get_record(NetSuite::Records::Invoice, params[:invoice_id])

  if ns_invoice.status == "Paid In Full"
    return erb :already_paid, locals: { invoice_number: ns_invoice.tran_id }
  end

  ns_customer = NetSuite::Utilities.get_record(NetSuite::Records::Customer, ns_invoice.entity.internal_id)

  # If a Stripe customer has been linked to a NetSuite customer,
  # the external ID will be a reference to a valid NetSuite customer

  # if a valid customer reference is found, you could display available
  # payment sources and allow payment from a previously saved card

  begin
    stripe_customer = Stripe::Customer.retrieve(ns_customer.external_id)
    stripe_customer_id = stripe_customer.id
  rescue
    stripe_customer_id = nil
  end

  invoice_total_in_cents = (ns_invoice.total.to_f * 100.0).to_i

  erb :pay, locals: {
    invoice_number: ns_invoice.tran_id,
    invoice_id: ns_invoice.internal_id,
    invoice_total: (ns_invoice.total.to_f * 100.0).to_i,
    invoice_due_date: ns_invoice.due_date,

    stripe_customer_id: stripe_customer_id,
    customer_email: ns_customer.email
  }
end

post '/pay' do
  token = params[:stripeToken]
  invoice_total = params[:invoice_total]

  # the token is used to create a one-time charge

  # instead of creating a one-time payment, you can add the card as a payment
  # source to the associated customer for easy reuse in the future

  begin
    charge = Stripe::Charge.create(
      :amount => invoice_total,
      :currency => 'usd',
      :source => token,

      # this description will be added to the memo field of the NetSuite customer payment
      :description => "Online NetSuite Invoice Payment",

      metadata: {
        # this metadata field instructs SuiteSync to create a CustomerPayment and apply it to the associated invoice
        netsuite_invoice_id: params[:invoice_id]

        # more metadata fields can be added to pass custom data over to the
      }
    )
  rescue Stripe::CardError => e
    raise e
  end

  erb :success
end
