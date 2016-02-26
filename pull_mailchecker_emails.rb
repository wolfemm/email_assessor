#!/usr/bin/env ruby

require "yaml"

require "json"
require "net/http"

whitelisted_domains = %w(poczta.onet.pl fastmail.fm hushmail.com naver.com)

existing_domains = File.readlines("vendor/disposable_domains.txt")

puts existing_domains.size

url = "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.json"
resp = Net::HTTP.get_response(URI.parse(url))

remote_domains = JSON.parse(resp.body).flatten - whitelisted_domains

puts "New domains found: #{(remote_domains - existing_domains).join(', ')}"

result_domains = (existing_domains + remote_domains).map(&:strip).uniq.sort

File.open("vendor/disposable_domains.txt", "w") { |f| f.write result_domains.join("\n") }
