describe OFX do
  empty_ofx = File.read(File.dirname(__FILE__) + "/sample-data/empty.ofx")
  ofx_with_info = File.read(File.dirname(__FILE__) + "/sample-data/with-bank-info.ofx")
  ofx_with_transaction = File.read(File.dirname(__FILE__) + "/sample-data/with-transaction.ofx")

  it "should generate empty OFX files" do
    ofx_builder = OFX::Builder.new do |ofx|
      ofx.dtserver = Date.new(2014,2,11)
    end
    
    ofx = ofx_builder.to_ofx
    expect( ofx ).to eq(empty_ofx)
  end

  it "should generate OFX files with bank info but no transactions" do
    ofx_builder = OFX::Builder.new do |ofx|
      ofx.dtserver = Date.new(2014,2,11)
      ofx.fi_org = "Stripe"
      ofx.fi_fid = "0"
      ofx.bank_id = "123456789"
      ofx.acct_id = "Test"
      ofx.acct_type = "CHECKING"
      ofx.dtstart = Date.new(2014,1,1)
      ofx.dtend = Date.new(2014,2,1)
      ofx.bal_amt = 0
      ofx.dtasof = Date.new(2014,2,1)
    end

    ofx = ofx_builder.to_ofx
    expect( ofx ).to eq(ofx_with_info)
  end


  it "should generate OFX files with transactions" do
    ofx_builder = OFX::Builder.new do |ofx|
      ofx.dtserver = Date.new(2014,2,11)
      ofx.fi_org = "Stripe"
      ofx.fi_fid = "0"
      ofx.bank_id = "123456789"
      ofx.acct_id = "Test"
      ofx.acct_type = "CHECKING"
      ofx.dtstart = Date.new(2014,1,1)
      ofx.dtend = Date.new(2014,2,1)
      ofx.bal_amt = 0
      ofx.dtasof = Date.new(2014,2,1)
    end

    ofx_builder.transaction do |ofx_tr|
      ofx_tr.dtposted = Date.new(2014,1,1)
      ofx_tr.trnamt = "100.23"
      ofx_tr.fitid = "Test"
      ofx_tr.name = "Name"
      ofx_tr.memo = "Memo memo"
    end

    ofx = ofx_builder.to_ofx
    expect( ofx ).to eq(ofx_with_transaction)
  end
end
