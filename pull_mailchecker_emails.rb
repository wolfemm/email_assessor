#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

require "json"
require "net/http"
require "set"
require_relative "lib/email_assessor/file_domain_list"
require_relative "lib/email_assessor/domain_token_set"

excluded_domains = EmailAssessor::FileDomainList.new("src/excluded_domains.txt")
existing_domains = File.readlines("src/disposable_domains.txt")

remote_domains = [
  "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.txt",
  "https://raw.githubusercontent.com/disposable/disposable-email-domains/master/domains.txt"
].flat_map do |url|
  resp = Net::HTTP.get_response(URI.parse(url))

  resp.body.split("\n").flatten
end

result_domains = Set.new((existing_domains + remote_domains).map! { |domain| domain.strip.downcase })
result_domains = result_domains.to_a
result_domains.delete_if { |domain| excluded_domains.include_any?(EmailAssessor::DomainTokenSet.parse(domain)) }
result_domains.sort!

File.open("src/disposable_domains.txt", "w") { |f| f.write result_domains.join("\n") }

require_relative "index_domains"