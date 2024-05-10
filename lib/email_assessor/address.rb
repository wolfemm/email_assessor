# frozen_string_literal: true
require "email_assessor"
require "resolv"
require "mail"

module EmailAssessor
  class Address
    attr_accessor :parsed

    PROHIBITED_DOMAIN_PREFIXES = [
      '.',
      '-',
    ].freeze

    PROHIBITED_DOMAIN_CONTENT = [
      '+',
      '!',
      '_',
      '/',
      ' ',
      '..',
      '-.',
      "'",
    ].freeze

    PROHIBITED_DOMAIN_SUFFIXES = [
      # none
    ].freeze

    PROHIBITED_LOCAL_PREFIXES = [
      '.',
    ].freeze

    PROHIBITED_LOCAL_CONTENT = [
      '..',
    ].freeze

    PROHIBITED_LOCAL_SUFFIXES = [
      '.',
    ].freeze

    class << self
      def prohibited_domain_regex
        @prohibited_domain_content_regex ||= make_regex(
          prefixes: PROHIBITED_DOMAIN_PREFIXES,
          content: PROHIBITED_DOMAIN_CONTENT,
          suffixes: PROHIBITED_DOMAIN_SUFFIXES
        )
      end

      def prohibited_local_regex
        @prohibited_local_content_regex ||= make_regex(
          prefixes: PROHIBITED_LOCAL_PREFIXES,
          content: PROHIBITED_LOCAL_CONTENT,
          suffixes: PROHIBITED_LOCAL_SUFFIXES
        )
      end

      private

      def make_regex(prefixes: nil, content: nil, suffixes: nil)
        parts = []

        unless prefixes.nil?
          prefixes.each do |prefix|
            parts << "\\A#{Regexp.escape(prefix)}"
          end
        end

        unless content.nil?
          content.each do |prefix|
            parts << Regexp.escape(prefix)
          end
        end

        unless suffixes.nil?
          suffixes.each do |prefix|
            parts << "#{Regexp.escape(prefix)}\\z"
          end
        end

        Regexp.new(parts.join("|"), Regexp::IGNORECASE)
      end
    end

    def initialize(raw_address)
      @parse_error = false
      @raw_address = raw_address
      @address = nil
      @valid = nil
      @mx_servers = nil
      @domain_tokens = nil

      begin
        @address = Mail::Address.new(raw_address)
      rescue Mail::Field::ParseError
        @parse_error = true
      end
    end

    def valid?
      return @valid unless @valid.nil?
      return false if @parse_error

      @valid =
        if @address.domain && @address.address == @raw_address
          domain = @address.domain

          domain.include?('.') &&
            !domain.match?(self.class.prohibited_domain_regex) &&
            !@address.local.match?(self.class.prohibited_local_regex)
        else
          false
        end
    end

    def disposable?
      domain_in_list?(EmailAssessor.disposable_domains)
    end

    def blacklisted?
      domain_in_list?(EmailAssessor.blacklisted_domains)
    end

    def educational?
      domain_in_list?(EmailAssessor.educational_domains)
    end

    def fastpass?
      domain_in_list?(EmailAssessor.fastpass_domains)
    end

    def valid_mx?
      valid? && mx_servers.any?
    end

    def mx_servers
      @mx_servers ||= Resolv::DNS.open do |dns|
        mx_servers = dns.getresources(@address.domain, Resolv::DNS::Resource::IN::MX)
        (mx_servers.any? && mx_servers) ||
          dns.getresources(@address.domain, Resolv::DNS::Resource::IN::A)
      end
    end

    private

    def domain_in_list?(list)
      valid? && list.include_any?(domain_tokens)
    end

    def domain_tokens
      @domain_tokens ||= EmailAssessor.tokenize_domain(@address.domain)
    end
  end
end
