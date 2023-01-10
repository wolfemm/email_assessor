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
    file_name ||= ""
    domain = domain.downcase

    File.foreach(file_name, chomp: true).any? do |line|
      # String#end_with? is used as a cheaper initial check but due to potential false positives
      # (hotmail.com is valid but tmail.com is not) regex is also necessary.
      domain.end_with?(line) && domain.match?(%r{\A(?:.*\.)?#{Regexp.escape(line)}\z}i)
    end
  end
end
