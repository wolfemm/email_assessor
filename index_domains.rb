#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"

%w[disposable_domains fastpass_domains educational_domains blacklisted_domains].each do |category|
  directory = File.join("assets", "data", category)

  files = {
    # char => File
  }
  hit_count = {
    # char => count
  }

  FileUtils.rm_rf(Dir.glob(File.join(directory, "*")))
  FileUtils.mkdir_p(directory) unless File.directory?(directory)

  File.foreach(File.join("src", "#{category}.txt"), chomp: true).each do |domain|
    char = domain.chr

    hit_count[char] ||= 0
    hit_count[char] += 1

    if files.key?(char)
      files[char].write("\n")
    end

    file = (files[char] ||= File.open(File.join(directory, "#{char}.txt"), mode: "a+"))

    file.write(domain)
  end

  File.write(File.join(directory, "_prioritization.txt"), hit_count.keys.sort_by { |char| hit_count[char] }.join(""))

  files.each_value(&:close)
end
