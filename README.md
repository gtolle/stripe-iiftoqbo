# Stripe IIF to QuickBooks Online QBO Translator

Do you use QuickBooks Online?

Did you export your transaction history from Stripe, hoping to import it into QuickBooks Online to do your taxes?

Did you realize that QBO doesn't support importing data from .IIF files, which is what Stripe gave you?

Then this tool might be helpful.

It takes an IIF file and produces a QBO file that you can import into QuickBooks Online.

## Usage

	ruby -Ilib bin/stripe-iiftoqbo MyCompanyName myfile.iif > myfile.qbo

Docs

	Stripe-iiftoqbo converts your list of transactions exported by Stripe
	(in .IIF format) into a .QBO file suitable for importing into
	QuickBooks Online.

	You need to provide a name for your account (anything you want, use
	the name from your Stripe account).

	You also need to provide the IIF file. :)

	The QBO file is printed to standard output. Send it to a file.
		
   	Usage: stripe-iiftoqbo [-p PAYMENTS_CSV_FILE] [-c] ACCOUNT_NAME IIF_FILE > myfile.qbo

 
