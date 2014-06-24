# encoding: utf-8
Gem::Specification.new do |s|
  s.name          = 'stripe-iiftoqbo'
  s.version       = '0.1.1'
  s.summary       = 'Stripe IIF-to-QBO converter for Quickbooks Online'
  s.description   = 'Converts Stripe\'s IIF transaction file into a QBO file for importing into Quickbooks Online. A QBO file is in OFX (Open Financial Exchange) format.'
  s.homepage      = 'https://github.com/gtolle/stripe-iiftoqbo'
  s.email         = ['gilman.tolle@gmail.com']
  s.authors       = ['Gilman Tolle']
  s.license       = 'MIT'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.executables << 'stripe-iiftoqbo'

  s.add_runtime_dependency 'bigdecimal', '~> 1.2'
  s.add_runtime_dependency 'nokogiri', '~> 1.6'
end
