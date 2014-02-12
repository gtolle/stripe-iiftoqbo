require "nokogiri"

require "ofx/transaction"

module OFX
  class Builder

    attr_accessor :fi_org
    attr_accessor :fi_fid
    attr_accessor :dtserver

    attr_accessor :bank_id
    attr_accessor :acct_id
    attr_accessor :acct_type  # CHECKING, SAVINGS, MONEYMRKT, CREDITLINE

    attr_accessor :dtstart
    attr_accessor :dtend

    attr_accessor :transactions

    attr_accessor :bal_amt
    attr_accessor :dtasof

    def initialize(&block)
      @headers = [
                  [ "OFXHEADER", "100" ],
                  [ "DATA", "OFXSGML" ],
                  [ "VERSION", "103" ],
                  [ "SECURITY", "NONE" ],
                  [ "ENCODING", "USASCII" ],
                  [ "CHARSET", "1252" ],
                  [ "COMPRESSION", "NONE" ],
                  [ "OLDFILEUID", "NONE" ],
                  [ "NEWFILEUID", "NONE" ]
                 ]
      @transactions = []
      self.dtserver = Date.today
      if block_given?
        yield self
      end
    end

    def bal_amt=(amt)
      @bal_amt = BigDecimal.new(amt)
    end

    def transaction(&block)
      transaction = OFX::Transaction.new
      yield transaction
      self.transactions.push transaction
    end

    def to_ofx
      print_headers +
        print_body
    end

    def print_headers
      @headers.map { |key, value| "#{key}:#{value}" }.join("\n") + "\n\n" 
    end

    def print_body
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.OFX {
          xml.SIGNONMSGSRSV1 {
            xml.SONRS {
              xml.STATUS {
                xml.CODE "0"
                xml.SEVERITY "INFO"
              }
              xml.DTSERVER format_datetime(self.dtserver)
              xml.LANGUAGE "ENG"
              xml.FI {
                xml.ORG self.fi_org
                xml.FID self.fi_fid
              }
              xml.send "INTU.BID", self.fi_fid
            }
          }
          xml.BANKMSGSRSV1 {
            xml.STMTTRNRS {
              xml.TRNUID "0"
              xml.STATUS {
                xml.CODE "0"
                xml.SEVERITY "INFO"
              }
              xml.STMTRS {
                xml.CURDEF "USD"
                xml.BANKACCTFROM {
                  xml.BANKID self.bank_id
                  xml.ACCTID self.acct_id
                  xml.ACCTTYPE self.acct_type
                }
                xml.BANKTRANLIST {
                  if self.dtstart
                    xml.DTSTART format_date(self.dtstart)
                  end
                  if self.dtend
                    xml.DTEND format_date(self.dtend)
                  end
                  self.transactions.each do |transaction|
                    xml.STMTTRN {
                      xml.TRNTYPE format_trntype(transaction.trnamt)
                      xml.DTPOSTED format_date(transaction.dtposted)
                      xml.TRNAMT format_amount(transaction.trnamt)
                      xml.FITID transaction.fitid
                      xml.NAME transaction.name
                      xml.MEMO transaction.memo
                    }
                  end
                }
                xml.LEDGERBAL {
                  if self.bal_amt
                    xml.BALAMT format_balance(self.bal_amt)
                  end
                  if self.dtasof
                    xml.DTASOF format_date(self.dtasof)
                  end
                }
              }
            }
          }
        }
      end
      builder.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)
    end

    def format_datetime(time)
      time.strftime("%Y%m%d000000")
    end

    def format_date(time)
      time.strftime("%Y%m%d")
    end

    def format_amount(amount)
      if amount > 0
        "+#{amount.to_s('F')}"
      else
        "#{amount.to_s('F')}"
      end
    end

    def format_trntype(amount)
      if amount > 0
        "CREDIT"
      else
        "DEBIT"
      end
    end

    def format_balance(balance)
      balance.to_s('F')
    end
  end
end
