require "email_assessor"
require "resolv"
require "mail"

module EmailAssessor
  class Address
    attr_accessor :address

    def initialize(address)
      @parse_error = false
      @raw_address = address

      begin
        @address = Mail::Address.new(address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end
    end

    def valid?
      return false if @parse_error

      if address.domain && address.address == @raw_address
        domain = address.domain

        domain.match?(/\./) && # Valid address domain must contain a period
          !domain.match?(/\.{2,}/) && # Valid address domain cannot have consecutive periods
          !domain.match?(/^\./) && # Valid address domain cannot start with a period
          domain.match?(/[a-z]\Z/i) # Valid address domain must end with letters
      else
        false
      end
    end

    def disposable?
      valid? && EmailAssessor.domain_is_disposable?(address.domain)
    end

    def blacklisted?
      valid? && EmailAssessor.domain_is_blacklisted?(address.domain)
    end

    def valid_mx?
      return false unless valid?

      mx = []

      Resolv::DNS.open do |dns|
        mx.concat dns.getresources(address.domain, Resolv::DNS::Resource::IN::MX)
      end

      mx.any?
    end
  end
end
