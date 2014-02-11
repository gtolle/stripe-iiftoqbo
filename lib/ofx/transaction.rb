module OFX
  class Transaction
    attr_accessor :trntype
    attr_accessor :dtposted
    attr_accessor :trnamt
    attr_accessor :fitid
    attr_accessor :name
    attr_accessor :memo

    def trnamt=(amt)
      @trnamt = BigDecimal.new(amt)
    end
  end
end
