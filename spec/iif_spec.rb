describe IIF do

  empty_iif = File.read(File.dirname(__FILE__) + "/sample-data/empty.iif")
  basic_iif = File.read(File.dirname(__FILE__) + "/sample-data/basic.iif")

  it "should parse empty IIF files" do
    iif = IIF( empty_iif )
    expect( iif.transactions.length ).to eq(0)
  end

  it "should parse basic IIF files" do
    iif = IIF( basic_iif )
    expect( iif.transactions.length ).to eq(8)
    first_transaction = iif.transactions[0]
    expect( first_transaction.entries.length ).to eq(2)
    first_entry = first_transaction.entries.first

    expect( first_entry.type ).to eq("TRNS")
    expect( first_entry.trnstype ).to eq("CHECK")
    expect( first_entry.date ).to eq(Date.new(2014,1,23))
    expect( first_entry.accnt ).to eq("Stripe Account")
    expect( first_entry.amount ).to eq(-135.15)
    expect( first_entry.memo ).to eq("Transfer from Stripe: tr_3MCmCnHFyYXFB5")

    second_entry = first_transaction.entries[1]

    expect( second_entry.type ).to eq("SPL")
    expect( second_entry.trnstype ).to eq("CHECK")
    expect( second_entry.date ).to eq(Date.new(2014,1,23))
    expect( second_entry.accnt ).to eq("Stripe Third-party Account")
    expect( second_entry.amount ).to eq(135.15)
    expect( second_entry.memo ).to eq("Transfer from Stripe: tr_3MCmCnHFyYXFB5")
    expect( second_entry.name ).to eq("Nicole Chiu-Wang")

    second_transaction = iif.transactions[1]

    first_entry = second_transaction.entries[0]

    expect( first_entry.type ).to eq("TRNS")
    expect( first_entry.trnstype ).to eq("GENERAL JOURNAL")
    expect( first_entry.date ).to eq(Date.new(2014,1,23))
    expect( first_entry.accnt ).to eq("Stripe Account")
    expect( first_entry.amount ).to eq(-0.25)
    expect( first_entry.memo ).to eq("Fees for Transfer from Stripe: tr_3MCmCnHFyYXFB5")

    second_entry = second_transaction.entries[1]

    expect( second_entry.type ).to eq("SPL")
    expect( second_entry.trnstype ).to eq("GENERAL JOURNAL")
    expect( second_entry.date ).to eq(Date.new(2014,1,23))
    expect( second_entry.accnt ).to eq("Stripe Payment Processing Fees")
    expect( second_entry.amount ).to eq(0.25)
    expect( second_entry.memo ).to eq("Fees for Transfer from Stripe: tr_3MCmCnHFyYXFB5")
  end
end
