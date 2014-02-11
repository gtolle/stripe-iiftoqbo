## Stripe IIF to QuickBooks Online QBO File Translator

Do you use QuickBooks Online?

Did you export your transaction history from Stripe, hoping to import it into QuickBooks Online to do your taxes?

Did you realize that QBO doesn't support importing data from .IIF files, which is what Stripe gave you?

Then this tool might be helpful.

Stripe-iiftoqbo takes an IIF file and produces a QBO file that you can import into QuickBooks Online.

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

Then, run the app:

	ruby -Ilib bin/stripe-iiftoqbo MyCompanyName myfile.iif > myfile.qbo

You'll get a nice .QBO file with all of your transactions on stdout.

Now, import it into QuickBooks Online.

If you want to merge descriptions from a 'payments' file, make sure it's the right one:

	$ head payments.csv
	id,Description,Created,Amount,Amount Refunded,Currency,Converted Amount,Converted Amount Refunded,Fee,Converted Currency,Mode,Status,Customer ID,Customer Description,Customer Email,Captured,Card Last4,Card Type,Card Exp Month,Card Exp Year,Card Name,Card Address Line1,Card Address Line2,Card Address City,Card Address State,Card Address Country,Card Address Zip,Card Issue Country,Card Fingerprint,Card CVC Status,Card AVS Zip Status,Card AVS Line1 Status,Dispute Status
	ch_3QSlijsVumgdnQ,,2014-02-03 01:47,19.00,0.00,usd,19.00,0.00,0.85,usd,Live,Paid,cus_29a92b191,test@test.com,,true,1111,Visa,1,2016,,,,,,,,US,ztg6Hv5g3sbjBE57,,,,
	ch_3PimG0oAu3LRSg,Test Description To Merge,2014-02-01 02:16,249.00,0.00,usd,249.00,0.00,7.52,usd,Live,Paid,cus_292ab3c2b,test@test.com,,true,2222,Visa,1,2016,,,,,,,,US,2Xv5QDDhdKj23Z0l,,,,


## Docs

Stripe-iiftoqbo converts your list of transactions exported by Stripe
(in .IIF format) into a .QBO file suitable for importing into
QuickBooks Online.

You need to provide a name for your account (anything you want, use
the name from your Stripe account).

You also need to provide the IIF file. :)

If you want to see a more readable CSV version of the output, give the
-c flag.

If you want your QBO 'memo' field augmented with the actual
description of each payment, then go to your Payments page and
export your transaction list CSV. Then specify that filename with -p.

	Usage: #{executable_name} [-p PAYMENTS_CSV_FILE] [-c] ACCOUNT_NAME IIF_FILE 
