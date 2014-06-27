## Stripe IIF to QuickBooks Online QBO File Translator

Does your company use Stripe to charge credit cards?

Does your company use QuickBooks Online for accounting?

Did you export your full transaction history from Stripe as an .IIF file?

Did you hope to import that transaction history into QuickBooks Online to do your taxes?

Did you realize that QBO doesn't support importing data from .IIF files, which is what Stripe gave you?

Then this tool might be helpful.

Stripe-iiftoqbo takes an IIF file and produces a QBO file that you can import into QuickBooks Online.

It's been tested with:

* Credit Card Payments
* Subscription Credit Card Payments
* Credit Card Refunds
* Transfers to our Checking Account
* Payouts to Third Parties
* Stripe Connect Fees Collected
* Stripe Connect Fees Refunded
* Stripe Transaction Fees

You can use the Stripe data to come up with top-line revenue numbers from credit card payments and cost of goods sold if you're a marketplace with payouts. You can also double-check that all the transfers from Stripe sync up with transfers into your bank account.

## Usage

	Usage: stripe-iiftoqbo [-p PAYMENTS_CSV_FILE] [-c] ACCOUNT_NAME IIF_FILE 

## Quickstart

First, get your IIF file from Stripe.

Go to your Stripe Dashboard, then your account menu, then Account Settings. Go to the Data tab, and hit "Export to Quickbooks". Choose your date range (e.g. all of 2013), and hit Export to IIF.

Double-check your file to make sure it's an .IIF.

	$ head balance_history.iif
	!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
	!SPL	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
	!ENDTRNS
	TRNS		PAYOUT (FIRST LAST)	01/23/2014	Third-party Account	135.15	Transfer from Stripe: tr_3MCmCnHFyYXFB5
	SPL		PAYOUT (FIRST LAST)	01/23/2014	Stripe Account	-135.4	Transfer from Stripe: tr_3MCmCnHFyYXFB5
	SPL		GENERAL JOURNAL	01/23/2014	Stripe Payment Processing Fees	0.25	Fees for transfer ID: tr_3MCmCnHFyYXFB5
	ENDTRNS

Pick a name for your company (e.g. MyCompanyName). It's going to be saved into the QBO file. I'd recommend using your Stripe Account Name.

Then, run the app:

	ruby -Ilib bin/stripe-iiftoqbo MyCompanyName balance_history.iif > balance_history.qbo

You'll get a nice .QBO file with all of your transactions.

Now, go to QuickBooks Online. Go to the 'gear' menu and hit 'Chart of Accounts'. Create a new 'Bank' > 'Checking' account and call it 'Stripe'.

Now go to the Transactions > Banking page. Hit the dropdown arrow next to Update and choose 'File Upload'.

Upload your new .QBO file. You should see the company name you specified, and a date range from the IIF file. Choose your 'Stripe' account from the QuickBooks Online dropdown.

You should see a line item for each:  

* Credit Card Charge you collected
* Stripe Fee you paid on that charge
* Transfer to your checking account
* Transfer to a third-party using Stripe Payounts
* Stripe Fee you paid on that transfer
* Stripe Connect Fee you collected
* Credit Card Charge that was refunded
* Refund of Stripe Fee for that charge	

Categorize and accept each transaction. Now you can see how much you made, how much you paid to Stripe, and how much you paid to your vendors.

## Extras

If you want to merge the description for each payment into the 'memo' field of your QBO file so you can see them in QuickBooks, go to the Stripe Payments page and export your payments as a CSV. It'll look like this:

	$ head payments.csv
	id,Description,Created,Amount,Amount Refunded,Currency,Converted Amount,Converted Amount Refunded,Fee,Converted Currency,Mode,Status,Customer ID,Customer Description,Customer Email,Captured,Card Last4,Card Type,Card Exp Month,Card Exp Year,Card Name,Card Address Line1,Card Address Line2,Card Address City,Card Address State,Card Address Country,Card Address Zip,Card Issue Country,Card Fingerprint,Card CVC Status,Card AVS Zip Status,Card AVS Line1 Status,Dispute Status
	ch_3QSlijsVumgdnQ,,2014-02-03 01:47,19.00,0.00,usd,19.00,0.00,0.85,usd,Live,Paid,cus_29a92b191,test@test.com,,true,1111,Visa,1,2016,,,,,,,,US,ztg6Hv5g3sbjBE57,,,,
	ch_3PimG0oAu3LRSg,Test Description To Merge,2014-02-01 02:16,249.00,0.00,usd,249.00,0.00,7.52,usd,Live,Paid,cus_292ab3c2b,test@test.com,,true,2222,Visa,1,2016,,,,,,,,US,2Xv5QDDhdKj23Z0l,,,,

Then, run the tool again with ```-p payments.csv```. For each charge in the IIF, if there's a matching Charge ID in the payments file, the tool will merge it into the QBO memo.

If you want to inspect the transactions from your .IIF file in CSV format (using Excel, for example), give the '-c' flag. It'll dump CSV instead of QBO.

## License

New MIT License - Copyright (c) 2014 Gilman Tolle

See LICENSE for details
