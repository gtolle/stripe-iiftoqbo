require 'csv'
require_relative 'iif'
require_relative 'ofx'

module StripeIIFToQBO
  class Converter
    def initialize( options={} )
      @account_id = options[:account_id] if options[:account_id]
      @iif_file = options[:iif_file] if options[:iif_file]
      @payments_file = options[:payments_file] if options[:payments_file]
      @transfers_file = options[:transfers_file] if options[:transfers_file]
      @server_time = options[:server_time] || Date.today

      load_payments_file(@payments_file)
      load_transfers_file(@transfers_file)
      load_iif_file(@iif_file)
    end

    def load_payments_file(payments_file)
      @payments = {}
      
      if payments_file
        CSV.foreach(payments_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
          @payments[row["id"]] = row["Description"] || ""
        end
      end
    end

    def load_transfers_file(transfers_file)
      @transfers = {}
      
      if transfers_file
        CSV.foreach(transfers_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
          @transfers[row["ID"]] = row["Description"] || ""
        end
      end
    end

    def load_iif_file(iif_file)
      @ofx_entries = []
          
      if iif_file
        IIF(iif_file) do |iif|
          iif.transactions.each do |transaction|
            transaction.entries.each do |iif_entry|
              ofx_entry = convert_iif_entry_to_ofx(iif_entry)
              if ofx_entry
                @ofx_entries.push( ofx_entry )
              end
            end
          end
        end
      end
    end
    
    def convert_iif_entry_to_ofx(iif_entry)
      ofx_entry = {}
      
      ofx_entry[:date] = iif_entry.date
      ofx_entry[:fitid] = iif_entry.memo
      ofx_entry[:accnt] = iif_entry.accnt
      ofx_entry[:trnstype] = iif_entry.trnstype
      ofx_entry[:memo] = iif_entry.memo

      case iif_entry.accnt

      when "Stripe Third-party Account"
        ofx_entry[:amount] = -iif_entry.amount
        ofx_entry[:name] = iif_entry.name

        ofx_entry[:memo] =~ /Transfer from Stripe: (\S+)/
        transfer_id = $1

        if @transfers[transfer_id]
          ofx_entry[:memo] = "#{@transfers[transfer_id]} #{iif_entry.memo}"
        end

      when "Stripe Payment Processing Fees"
        ofx_entry[:amount] = -iif_entry.amount
        ofx_entry[:name] = "Stripe"

      when "Stripe Checking Account"
        ofx_entry[:amount] = -iif_entry.amount
        ofx_entry[:name] = "Transfer to #{iif_entry.accnt}"

     when "Stripe Sales"
        ofx_entry[:amount] = -iif_entry.amount
        
        if iif_entry.memo =~ /Stripe Connect fee/
          ofx_entry[:name] = "Stripe Connect Charge"
        elsif iif_entry.memo =~ /Charge/
          ofx_entry[:name] = "Credit Card Charge"
        else
          ofx_entry[:name] = iif_entry.accnt
        end
        
        ofx_entry[:memo] =~ /Charge ID: (\S+)/
        charge_id = $1

        if @payments[charge_id]
          ofx_entry[:memo] = "#{@payments[charge_id]} Charge ID: #{charge_id}"
          ofx_entry[:fitid] = charge_id
        end

      when "Stripe Returns"
        ofx_entry[:amount] = -iif_entry.amount
        ofx_entry[:name] = "Credit Card Refund"

        ofx_entry[:memo] =~ /Refund of charge (\S+)/
        charge_id = $1

        if @payments[charge_id]
          ofx_entry[:memo] = "#{@payments[charge_id]} Refund of Charge ID: #{charge_id}"
        end

      when "Stripe Account"
        return nil
      end

      return ofx_entry
    end

    def to_csv
      rows = []
      rows.push(["Date", "Name", "Account", "Memo", "Amount"].to_csv)
      @ofx_entries.each do |ofx_entry|
        rows.push([ ofx_entry[:date].strftime("%m/%d/%Y"), ofx_entry[:name], ofx_entry[:accnt], "#{ofx_entry[:trnstype]} #{ofx_entry[:memo]}", ofx_entry[:amount].to_s('F') ].to_csv)
      end
      return rows.join
    end
    
    def to_qbo
      min_date = nil
      max_date = nil
      
      @ofx_entries.each do |e|
        if e[:date]
          min_date = e[:date] if min_date.nil? or e[:date] < min_date
          max_date = e[:date] if max_date.nil? or e[:date] > max_date
        end
      end
      
      ofx_builder = OFX::Builder.new do |ofx|
        ofx.dtserver = @server_time
        ofx.fi_org = "Stripe"
        ofx.fi_fid = "0"
        ofx.bank_id = "123456789"
        ofx.acct_id = @account_id
        ofx.acct_type = "CHECKING"
        ofx.dtstart = min_date
        ofx.dtend = max_date
        ofx.bal_amt = 0
        ofx.dtasof = max_date
      end
      
      @ofx_entries.each do |ofx_entry|
        ofx_builder.transaction do |ofx_tr|
          ofx_tr.dtposted = ofx_entry[:date]
          ofx_tr.trnamt = ofx_entry[:amount]
          ofx_tr.fitid = ofx_entry[:fitid]
          ofx_tr.name = ofx_entry[:name]
          ofx_tr.memo = ofx_entry[:memo]
        end
      end
      
      return ofx_builder.to_ofx
    end
  end
end
