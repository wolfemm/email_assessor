require "email_assessor/email_validator"

module EmailAssessor
  def self.domain_is_disposable?(domain)
    domain_in_file?(domain, configuration.disposable_domains_file_name)
  end

  def self.domain_is_blacklisted?(domain)
    domain_in_file?(domain, configuration.blacklisted_domains_file_name)
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :disposable_domains_file_name, :blacklisted_domains_file_name

    def initialize
      @disposable_domains_file_name = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)
      @blacklisted_domains_file_name = File.expand_path("vendor/blacklisted_domains.txt")
    end
  end

  protected

  def self.domain_in_file?(domain, file_name)
    return false unless file_name.present? && File.exists?(file_name)

    domain = domain.downcase
    domain_matched = false

    File.open(file_name).each do |line|
      if domain.end_with?(line.chomp)
        domain_matched = true
        break
      end
    end

    domain_matched
  end
end
