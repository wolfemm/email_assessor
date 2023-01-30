# frozen_string_literal: true
require "email_assessor/email_validator"

module EmailAssessor
  DISPOSABLE_DOMAINS_FILE_NAME = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)
  FASTPASS_DOMAINS_FILE_NAME = File.expand_path("../../vendor/fastpass_domains.txt", __FILE__)
  EDUCATIONAL_DOMAINS_FILE_NAME = File.expand_path("../../vendor/educational_domains.txt", __FILE__)
  BLACKLISTED_DOMAINS_FILE_NAME = File.expand_path("vendor/blacklisted_domains.txt")

  def self.domain_is_disposable?(domain)
    domain_in_file?(domain, DISPOSABLE_DOMAINS_FILE_NAME)
  end

  def self.domain_is_blacklisted?(domain)
    domain_in_file?(domain, BLACKLISTED_DOMAINS_FILE_NAME)
  end

  def self.domain_in_file?(domain, file_name)
    any_token_in_file?(tokenize_domain(domain.downcase), file_name)
  end

  def self.any_token_in_file?(domain_tokens, file_name)
    file_name ||= ""

    File.foreach(file_name, chomp: true).any? do |line|
      domain_tokens.key?(line)
    end
  end

  def self.tokenize_domain(domain)
    parts = domain.split(".")
    tokens = {}

    loop do
      tokens[parts.join(".")] = nil

      parts.shift

      break if parts.empty?
    end

    tokens
  end
end
