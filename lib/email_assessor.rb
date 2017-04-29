require "email_assessor/email_validator"

module EmailAssessor
  DISPOSABLE_DOMAINS_FILE_NAME = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)
  BLACKLISTED_DOMAINS_FILE_NAME = File.expand_path("vendor/blacklisted_domains.txt")

  def self.domain_is_disposable?(domain)
    domain_in_file?(domain, DISPOSABLE_DOMAINS_FILE_NAME)
  end

  def self.domain_is_blacklisted?(domain)
    domain_in_file?(domain, BLACKLISTED_DOMAINS_FILE_NAME)
  end

  protected

  def self.domain_in_file?(domain, file_name)
    file_name ||= ""
    domain = domain.downcase

    # Using String#end_with? here would lead to unexpected quirks and false positives.
    # For instance, hotmail.com is valid but tmail.com is not.
    File.foreach(file_name).any? { |line| domain.match?(%r{\A(?:.+\.)*?#{line.chomp}\z}i) }
  end
end
