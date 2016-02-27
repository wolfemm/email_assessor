require "valid_email2/email_validator"

module ValidEmail2
  DISPOSABLE_DOMAINS_FILE = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)
  BLACKLISTED_DOMAINS_FILE = File.expand_path("../../vendor/blacklisted_domains.txt", __FILE__)

  def self.domain_is_disposable?(domain)
    domain_in_file?(domain, DISPOSABLE_DOMAINS_FILE)
  end

  def self.domain_is_blacklisted?(domain)
    domain_in_file?(domain, BLACKLISTED_DOMAINS_FILE)
  end

  protected

  def self.domain_in_file?(domain, filename)
    return false unless File.exists?(filename)

    domain_matched = false

    File.open(DISPOSABLE_DOMAINS_FILE).each do |line|
      if domain.include?(line.chomp)
        domain_matched = true
        break
      end
    end

    domain_matched
  end
end
