require 'iif/parser'

def IIF(resource, &block)
  parser = IIF::Parser.new(resource)
  
  if block_given?
    if block.arity == 1
      yield parser
    else
      parser.instance_eval(&block)
    end
  end

  parser
end
