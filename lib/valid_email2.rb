require "valid_email2/email_validator"

module ValidEmail2
  DISPOSABLE_DOMAINS_FILE = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)

  def self.domain_is_disposable?(domain)
    is_disposable = false

    File.open(DISPOSABLE_DOMAINS_FILE).each do |line|
      if domain.include?(line.chomp)
        is_disposable = true
        break
      end
    end

    is_disposable
  end

  def self.blacklist
    blacklist_file = "vendor/blacklist.yml"
    @@blacklist ||= File.exists?(blacklist_file) ? YAML.load_file(File.expand_path(blacklist_file)) : []
  end
end
