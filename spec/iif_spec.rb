describe IIF do

  empty_iif = File.read(File.dirname(__FILE__) + "/sample-data/empty.iif")
  basic_iif = File.read(File.dirname(__FILE__) + "/sample-data/basic.iif")

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
