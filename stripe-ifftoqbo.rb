require 'optparse'
require 'bigdecimal'
require 'csv'
require 'pp'

require 'iif'
require 'ofx'

dump_csv = false

account_id = ARGV[0]
iif_file = ARGV[1]
payments_file = ARGV[2]

charges = {}

CSV.foreach(payments_file, :headers => true) do |row|
  charges[row["id"]] = row["Description"] || ""
end

IIF(iif_file) do |iif|
  transactions = []

  iif.transactions.each do |transaction|
    transaction[:entries].each do |entry|
      should_print = true

      entry[:fitid] = entry[:memo]

      case entry[:accnt]

      when "Third-party Account"
        entry[:amount] = -entry[:amount]
        entry[:name] = entry[:trnstype].gsub(/PAYOUT \((.*?)\)/, '\1').split(/(\W)/).map(&:capitalize).join
      when "Stripe Payment Processing Fees"
        entry[:amount] = -entry[:amount]
        entry[:name] = "Stripe"
      when "Checking Account"
        entry[:amount] = -entry[:amount]
        entry[:name] = "Transfer to #{entry[:accnt]}"
      when "Stripe Sales"
        entry[:amount] = -entry[:amount]

        if entry[:memo] =~ /Stripe Connect fee/
          entry[:name] = "Stripe Connect Charge"
        elsif entry[:memo] =~ /Charge/
          entry[:name] = "Credit Card Charge"
        else
          entry[:name] = entry[:accnt]
        end

        entry[:memo] =~ /Charge ID: (.*)/
        charge_id = $1
        entry[:memo] = "#{charges[charge_id]} #{entry[:memo]}"

      when "Stripe Returns"
        entry[:amount] = -entry[:amount]
        entry[:name] = "Credit Card Refund"
      when "Stripe Account"
        should_print = false
      end

      if should_print
        transactions.push( entry )
      end
    end
  end

  if dump_csv
    puts ["Date", "Name", "Account", "Memo", "Amount"].to_csv
    transactions.each do |tr|
      puts [ tr[:date].strftime("%m/%d/%Y"), tr[:name], tr[:accnt], "#{tr[:trnstype]} #{tr[:memo]}", tr[:amount].to_s('F') ].to_csv
    end
  end

  min_date = nil
  max_date = nil
  transactions.each do |e|
    if e[:date]
      min_date = e[:date] if min_date.nil? or e[:date] < min_date
      max_date = e[:date] if max_date.nil? or e[:date] > max_date
    end
  end

  ofx_builder = OFX::Builder.new do |ofx|
    ofx.fi_org = "Stripe"
    ofx.fi_fid = "0"
    ofx.bank_id = "123456789"
    ofx.acct_id = account_id
    ofx.acct_type = "CHECKING"
    ofx.dtstart = min_date
    ofx.dtend = max_date
    ofx.bal_amt = BigDecimal.new("0.0")
    ofx.dtasof = max_date
  end

  transactions.each do |tr|
    ofx_builder.transaction do |ofx_tr|
      ofx_tr.dtposted = tr[:date]
      ofx_tr.trnamt = tr[:amount]
      ofx_tr.fitid = tr[:fitid]
      ofx_tr.name = tr[:name]
      ofx_tr.memo = tr[:memo]
    end
  end

  puts ofx_builder.to_ofx
end
