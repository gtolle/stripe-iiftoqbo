## Stripe IIF to QuickBooks Online QBO File Translator

Does your company use Stripe to charge credit cards?

Does your company use QuickBooks Online for accounting?

Did you export your full transaction history from Stripe as an IIF file?

Did you hope to import that transaction history into QuickBooks Online to do your taxes?

Did you realize that QBO doesn't support importing data from .IIF files, which is what Stripe gave you?

Then this tool might be helpful.

Stripe-iiftoqbo takes an IIF file and produces a QBO file that you can import into QuickBooks Online.

It's pretty hacky, and I've only tested it for my use case. My IIF file had:
	
* Credit Card Payments
* Subscription Credit Card Payments
* Credit Card Refunds
* Transfers to our Checking Account
* Payouts to Third Parties
* Stripe Connect Fees Collected
* Stripe Connect Fees Refunded
* … and Stripe Transaction Fees, of course :)

But now our 2013 taxes are done! 

I used the Stripe export to come up with our top-line revenue (from credit card payments), and our cost of goods sold (since we're a marketplace, that's payouts to vendors and stripe fees). And all the transfers to our checking account tallied with transfers into our checking account (as seen by our bank).

## Usage

	Usage: stripe-iiftoqbo [-p PAYMENTS_CSV_FILE] [-c] ACCOUNT_NAME IIF_FILE 

## Quickstart

First, make sure you have an IIF file.

	$ head myfile.iif
	!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
	!SPL	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
	!ENDTRNS
	TRNS		PAYOUT (FIRST LAST)	01/23/2014	Third-party Account	135.15	Transfer from Stripe: tr_3MCmCnHFyYXFB5
	SPL		PAYOUT (FIRST LAST)	01/23/2014	Stripe Account	-135.4	Transfer from Stripe: tr_3MCmCnHFyYXFB5
	SPL		GENERAL JOURNAL	01/23/2014	Stripe Payment Processing Fees	0.25	Fees for transfer ID: tr_3MCmCnHFyYXFB5
	ENDTRNS

Pick a name for your company (e.g. MyCompanyName). It's going to be saved into the QBO file.

Then, run the app:

	ruby -Ilib bin/stripe-iiftoqbo MyCompanyName myfile.iif > myfile.qbo

You'll get a nice .QBO file with all of your transactions on stdout.

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

If you want to merge descriptions from a 'payments' file (-p) into the 'memo' field of your QBO, go to the Stripe Payments page and Export them as CSV. It'll look like this:

	$ head payments.csv
	id,Description,Created,Amount,Amount Refunded,Currency,Converted Amount,Converted Amount Refunded,Fee,Converted Currency,Mode,Status,Customer ID,Customer Description,Customer Email,Captured,Card Last4,Card Type,Card Exp Month,Card Exp Year,Card Name,Card Address Line1,Card Address Line2,Card Address City,Card Address State,Card Address Country,Card Address Zip,Card Issue Country,Card Fingerprint,Card CVC Status,Card AVS Zip Status,Card AVS Line1 Status,Dispute Status
	ch_3QSlijsVumgdnQ,,2014-02-03 01:47,19.00,0.00,usd,19.00,0.00,0.85,usd,Live,Paid,cus_29a92b191,test@test.com,,true,1111,Visa,1,2016,,,,,,,,US,ztg6Hv5g3sbjBE57,,,,
	ch_3PimG0oAu3LRSg,Test Description To Merge,2014-02-01 02:16,249.00,0.00,usd,249.00,0.00,7.52,usd,Live,Paid,cus_292ab3c2b,test@test.com,,true,2222,Visa,1,2016,,,,,,,,US,2Xv5QDDhdKj23Z0l,,,,

Run the app again with ```-p payments.csv```.

If you want to inspect the transactions from your .IIF file in CSV format (using Excel, for example), give the '-c' flag. It'll dump CSV instead of QBO.

## License

New MIT License - Copyright (c) 2014, Gilman Tolle

See LICENSE for details
