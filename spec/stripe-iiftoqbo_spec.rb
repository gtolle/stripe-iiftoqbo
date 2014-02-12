describe StripeIIFToQBO do
  empty_qbo = <<EOS
OFXHEADER:100
DATA:OFXSGML
VERSION:103
SECURITY:NONE
ENCODING:USASCII
CHARSET:1252
COMPRESSION:NONE
OLDFILEUID:NONE
NEWFILEUID:NONE

<OFX><SIGNONMSGSRSV1><SONRS><STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS><DTSERVER>20140211000000</DTSERVER><LANGUAGE>ENG</LANGUAGE><FI><ORG>Stripe</ORG><FID>0</FID></FI><INTU.BID>0</INTU.BID></SONRS></SIGNONMSGSRSV1><BANKMSGSRSV1><STMTTRNRS><TRNUID>0</TRNUID><STATUS><CODE>0</CODE><SEVERITY>INFO</SEVERITY></STATUS><STMTRS><CURDEF>USD</CURDEF><BANKACCTFROM><BANKID>123456789</BANKID><ACCTID/><ACCTTYPE>CHECKING</ACCTTYPE></BANKACCTFROM><BANKTRANLIST/><LEDGERBAL><BALAMT>0.0</BALAMT></LEDGERBAL></STMTRS></STMTTRNRS></BANKMSGSRSV1></OFX>
EOS

  empty_csv = <<EOS
Date,Name,Account,Memo,Amount
EOS

  it "should create an empty QBO file" do
    iiftoqbo = StripeIIFToQBO::Converter.new( :server_time => Date.new(2014,2,11) )
    qbo = iiftoqbo.to_qbo
    expect( qbo ).to eq(empty_qbo)
  end

  it "should create an empty CSV file" do
    iiftoqbo = StripeIIFToQBO::Converter.new( :server_time => Date.new(2014,2,11) )
    csv = iiftoqbo.to_csv
    expect( csv ).to eq(empty_csv)
  end
end
