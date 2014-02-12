describe StripeIIFToQBO do
  empty_qbo = File.read(File.dirname(__FILE__) + "/sample-data/empty.qbo")
  empty_csv = File.read(File.dirname(__FILE__) + "/sample-data/empty.csv")
  basic_iif = File.read(File.dirname(__FILE__) + "/sample-data/basic.iif")
  basic_qbo = File.read(File.dirname(__FILE__) + "/sample-data/basic.qbo")
  basic_csv = File.read(File.dirname(__FILE__) + "/sample-data/basic.csv")

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

  it "should create a basic QBO file" do
    iiftoqbo = StripeIIFToQBO::Converter.new( :server_time => Date.new(2014,2,11), :iif_file => basic_iif )
    qbo = iiftoqbo.to_qbo
    expect( qbo ).to eq(basic_qbo)
  end

  it "should create a basic CSV file" do
    iiftoqbo = StripeIIFToQBO::Converter.new( :server_time => Date.new(2014,2,11), :iif_file => basic_iif )
    csv = iiftoqbo.to_csv
    expect( csv ).to eq(basic_csv)
  end
end
