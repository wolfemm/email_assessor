#!/usr/bin/env ruby

require "yaml"

require "json"
require "net/http"

whitelisted_emails = %w(poczta.onet.pl fastmail.fm hushmail.com naver.com)

existing_emails = File.readlines("vendor/disposable_emails.txt")

puts existing_emails.size

url = "https://raw.githubusercontent.com/FGRibreau/mailchecker/master/list.json"
resp = Net::HTTP.get_response(URI.parse(url))

remote_emails = JSON.parse(resp.body).flatten - whitelisted_emails

puts "New emails found: #{remote_emails.join(', ')}"

result_emails = (existing_emails + remote_emails).map(&:strip).uniq.sort

File.open("vendor/disposable_emails.txt", "w") { |f| f.write result_emails.join("\n") }
