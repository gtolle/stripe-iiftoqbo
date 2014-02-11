describe IIF do
  empty_iif = ""
  basic_iif = <<EOS
!TRNS	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
!SPL	TRNSID	TRNSTYPE	DATE	ACCNT	AMOUNT	MEMO
!ENDTRNS
TRNS		PAYOUT (TEST USER)	01/23/2014	Third-party Account	135.15	Transfer from Stripe: tr_3MCmCnHFyYXFB5
SPL		PAYOUT (TEST USER)	01/23/2014	Stripe Account	-135.4	Transfer from Stripe: tr_3MCmCnHFyYXFB5
SPL		GENERAL JOURNAL	01/23/2014	Stripe Payment Processing Fees	0.25	Fees for transfer ID: tr_3MCmCnHFyYXFB5
ENDTRNS
TRNS		DEPOSIT	01/23/2014	Checking Account	85.0	Transfer from Stripe: tr_3MCmQsVsNuIX7J
SPL		DEPOSIT	01/23/2014	Stripe Account	-85.0	Transfer from Stripe: tr_3MCmQsVsNuIX7J
ENDTRNS
TRNS		GENERAL JOURNAL	01/22/2014	Stripe Sales	-249.0	Charge ID: ch_3M1PskZ2rglde3
SPL		GENERAL JOURNAL	01/22/2014	Stripe Payment Processing Fees	7.52	Fees for charge ID: ch_3M1PskZ2rglde3
SPL		GENERAL JOURNAL	01/22/2014	Stripe Account	241.48	Net for charge ID: ch_3M1PskZ2rglde3
ENDTRNS
TRNS		GENERAL JOURNAL	07/10/2013	Stripe Returns	60.0	Refund of charge ch_2AaUvVOXTJxqgU
SPL		GENERAL JOURNAL	07/10/2013	Stripe Account	-57.96	Refund for refunded charge ID: ch_2AaUvVOXTJxqgU
SPL		GENERAL JOURNAL	07/10/2013	Stripe Payment Processing Fees	-2.04	Refund of fees for ch_2AaUvVOXTJxqgU
ENDTRNS
TRNS		GENERAL JOURNAL	07/10/2013	Stripe Sales	-60.0	Charge ID: ch_2AaUVt4SQVF5mE
SPL		GENERAL JOURNAL	07/10/2013	Stripe Payment Processing Fees	2.04	Fees for charge ID: ch_2AaUVt4SQVF5mE
SPL		GENERAL JOURNAL	07/10/2013	Stripe Account	57.96	Net for charge ID: ch_2AaUVt4SQVF5mE
ENDTRNS
TRNS		DEPOSIT	12/10/2012	Checking Account	15.0	Transfer from Stripe: ach_0qt6m5dlIL2XMq
SPL		DEPOSIT	12/10/2012	Stripe Account	-15.0	Transfer from Stripe: ach_0qt6m5dlIL2XMq
ENDTRNS
TRNS		GENERAL JOURNAL	12/03/2012	Stripe Sales	-15.0	Stripe Connect fee for transaction ID: ch_0qbUpzmgBi6WVJ
SPL		GENERAL JOURNAL	12/03/2012	Stripe Account	15.0	Stripe Connect fee for transaction ID: ch_0qbUpzmgBi6WVJ
ENDTRNS
EOS

  it "should parse empty IIF files" do
    iif = IIF( empty_iif )
    expect( iif.transactions.length ).to eq(0)
  end

  it "should parse basic IIF files" do
    iif = IIF( basic_iif )
    expect( iif.transactions.length ).to eq(7)
    first_transaction = iif.transactions.first
    expect( first_transaction.entries.length ).to eq(3)
    first_entry = first_transaction.entries.first

    expect( first_entry.type ).to eq("TRNS")
    expect( first_entry.trnstype ).to eq("PAYOUT (TEST USER)")
    expect( first_entry.date ).to eq(Date.new(2014,1,23))
    expect( first_entry.accnt ).to eq("Third-party Account")
    expect( first_entry.amount ).to eq(135.15)
    expect( first_entry.memo ).to eq("Transfer from Stripe: tr_3MCmCnHFyYXFB5")

    second_entry = first_transaction.entries[1]

    expect( second_entry.type ).to eq("SPL")
    expect( second_entry.trnstype ).to eq("PAYOUT (TEST USER)")
    expect( second_entry.date ).to eq(Date.new(2014,1,23))
    expect( second_entry.accnt ).to eq("Stripe Account")
    expect( second_entry.amount ).to eq(-135.40)
    expect( second_entry.memo ).to eq("Transfer from Stripe: tr_3MCmCnHFyYXFB5")

    third_entry = first_transaction.entries[2]

    expect( third_entry.type ).to eq("SPL")
    expect( third_entry.trnstype ).to eq("GENERAL JOURNAL")
    expect( third_entry.date ).to eq(Date.new(2014,1,23))
    expect( third_entry.accnt ).to eq("Stripe Payment Processing Fees")
    expect( third_entry.amount ).to eq(0.25)
    expect( third_entry.memo ).to eq("Fees for transfer ID: tr_3MCmCnHFyYXFB5")
  end
end
