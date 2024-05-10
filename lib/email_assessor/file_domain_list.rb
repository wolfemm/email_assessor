# frozen_string_literal: true

module EmailAssessor
  class FileDomainList
    attr_reader :pathname

    def include_any?(domain_token_set)
      File.foreach(@pathname, chomp: true).any? do |domain|
        domain_token_set.include?(domain)
      end
    end

    def sample
      File.open(@pathname, &:readline).chomp
    end

    private

    def initialize(pathname)
      @pathname = pathname
    end
  end
end
