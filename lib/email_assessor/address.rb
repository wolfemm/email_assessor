# frozen_string_literal: true
require "email_assessor"
require "resolv"
require "mail"

module EmailAssessor
  class Address
    attr_accessor :address

    PROHIBITED_DOMAIN_CHARACTERS_REGEX = %r{[+!_\/\s']}

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

        !domain.match?(PROHIBITED_DOMAIN_CHARACTERS_REGEX) &&
        !domain.start_with?("-") && # Domain may not start with a hyphen
        !domain.include?("-.") && # Domain name may not end with a hyphen
        domain.include?(".") && # Domain must contain a period
        !domain.include?("..") && # Domain may not contain consecutive periods
        !address.address.include?(".@") && # Address may not contain a dot directly before @
        !domain.start_with?(".") && # Domain may not start with a period
        domain.match?(%r{[a-z]\z}i) # Domain must end with letters
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
      valid? && mx_servers.any?
    end

    def mx_server_is_in?(domain_list_file)
      mx_servers.any? do |mx_server|
        return false unless mx_server.respond_to?(:exchange)
        mx_server = mx_server.exchange.to_s

        EmailAssessor.domain_in_file?(mx_server, domain_list_file)
      end
    end

    def mx_servers
      @mx_servers ||= Resolv::DNS.open do |dns|
        mx_servers = dns.getresources(address.domain, Resolv::DNS::Resource::IN::MX)
        (mx_servers.any? && mx_servers) ||
          dns.getresources(address.domain, Resolv::DNS::Resource::IN::A)
      end
    end
  end
end
