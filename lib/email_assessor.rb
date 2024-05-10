# frozen_string_literal: true

require "email_assessor/email_validator"
require "email_assessor/directory_domain_list"
require "email_assessor/file_domain_list"
require "email_assessor/empty_domain_list"
require "email_assessor/domain_token_set"

module EmailAssessor
  class << self
    def tokenize_domain(domain)
      EmailAssessor::DomainTokenSet.parse(domain)
    end

    def [](pathname)
      @domain_list_cache ||= {
        # {pathname} => {domain list}
      }

      return @domain_list_cache[pathname] if @domain_list_cache.key?(pathname)

      list = if File.directory?(pathname)
        DirectoryDomainList.new(pathname)
      elsif File.file?(pathname)
        FileDomainList.new(pathname)
      end

      @domain_list_cache[pathname] = list

      list
    end

    def disposable_domains
      @disposable_domains ||= default_domain_list("disposable_domains")
    end

    def disposable_domains=(pathname)
      @disposable_domains = self[pathname]
    end

    def blacklisted_domains
      @blacklisted_domains ||= default_domain_list("blacklisted_domains")
    end

    def blacklisted_domains=(pathname)
      @blacklisted_domains = self[pathname]
    end

    def educational_domains
      @educational_domains ||= default_domain_list("educational_domains")
    end

    def educational_domains=(pathname)
      @educational_domains = self[pathname]
    end

    def fastpass_domains
      @fastpass_domains ||= default_domain_list("fastpass_domains")
    end

    def fastpass_domains=(pathname)
      @fastpass_domains = self[pathname]
    end

    private

    def default_domain_list(category)
      self[File.expand_path("../../vendor/#{category}.txt", __FILE__)] ||
        self[File.expand_path("../../vendor/#{category}", __FILE__)] ||
        self[File.expand_path("../../assets/data/#{category}.txt", __FILE__)] ||
        self[File.expand_path("../../assets/data/#{category}", __FILE__)] ||
        EmptyDomainList.instance
    end
  end
end
