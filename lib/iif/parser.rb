require 'bigdecimal'

require_relative 'transaction'
require_relative 'entry'

module IIF
  class Parser
    attr_accessor :definitions
    attr_accessor :entries
    attr_accessor :transactions

    def initialize(resource)
      @definitions = {}
      @entries = []
      @transactions = []

      resource = open_resource(resource)
      resource.rewind
      parse_file(resource)
      create_transactions
    end

    def open_resource(resource)
      if resource.respond_to?(:read)
        resource
      else
        open(resource)
      end
    rescue Exception
      StringIO.new(resource)
    end

    def parse_file(resource)
      resource.each_line do |line|
        fields = line.strip.split(/\t/)
        if fields[0][0] == '!'
          parse_definition(fields)
        else
          parse_data(fields)
        end
      end
    end
    
    def parse_definition(fields)
      key = fields[0][1..-1]
      values = fields[1..-1]
      @definitions[key] = values.map { |v| v.downcase }
    end

    def parse_data(fields)
      definition = @definitions[fields[0]]

      entry = Entry.new
      entry.type = fields[0]
      
      fields[1..-1].each_with_index do |field, idx|
        entry.send(definition[idx] + "=", field)
      end

      entry.amount = BigDecimal.new(entry.amount) if entry.amount
      entry.date = Date.strptime(entry.date, "%m/%d/%Y") if entry.date

      @entries.push(entry)
    end

    def create_transactions
      transaction = nil
      in_transaction = false

      @entries.each do |entry|
        
        case entry.type

        when "TRNS"
          if in_transaction
            @transactions.push(transaction)
            in_transaction = false
          end
          transaction = Transaction.new
          in_transaction = true
          
        when "ENDTRNS"
          @transactions.push(transaction)
          in_transaction = false

        end

        transaction.entries.push(entry) if in_transaction
      end
    end
  end
end
