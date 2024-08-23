#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

require "json"
require "net/http"
require "set"

whitelisted_domains = %w(poczta.onet.pl fastmail.fm hushmail.com naver.com qq.com nus.edu.sg)

existing_domains = File.readlines("src/disposable_domains.txt")

url = "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.txt"
resp = Net::HTTP.get_response(URI.parse(url))

remote_domains = (resp.body.split("\n")) - whitelisted_domains

result_domains = Set.new((existing_domains + remote_domains).map! { |domain| domain.strip.downcase })
result_domains = result_domains.to_a
result_domains.sort!

File.open("src/disposable_domains.txt", "w") { |f| f.write result_domains.join("\n") }
