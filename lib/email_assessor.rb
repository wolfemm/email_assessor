require "email_assessor/email_validator"

module EmailAssessor
  def self.domain_is_disposable?(domain)
    domain_in_file?(domain, configuration.disposable_domains_file_name)
  end

  def self.domain_is_blacklisted?(domain)
    domain_in_file?(domain, configuration.blacklisted_domains_file_name)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :disposable_domains_file_name, :blacklisted_domains_file_name

    def initialize
      @disposable_domains_file_name = File.expand_path("../../vendor/disposable_domains.txt", __FILE__)

      # no default blacklisted_domains_file_name
      @blacklisted_domains_file_name = ""
    end
  end

  protected

  def self.domain_in_file?(domain, file_name)
    file_name ||= ""
    domain = domain.downcase

    File.open(file_name).each_line.any? { |line| domain.end_with?(line) }
  end
end
