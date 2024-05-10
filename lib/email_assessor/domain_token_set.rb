# frozen_string_literal: true

module EmailAssessor
  class DomainTokenSet
    class << self
      def parse(domain)
        parts = domain.downcase.split(".")
        indexed_tokens = {
          # {first_char} => { {segment} => nil }
        }

        parts.length.times do
          segment = parts.join(".").freeze

          (indexed_tokens[segment.chr] ||= Hash.new)[segment] = nil

          parts.shift
        end

        indexed_tokens.each_value(&:freeze)
        indexed_tokens.freeze

        new(indexed_tokens)
      end
    end

    def include?(domain)
      tokens_of_char = @indexed_tokens[domain.chr]

      return false if tokens_of_char.nil?

      tokens_of_char.key?(domain)
    end

    def indexes
      @indexes ||= @indexed_tokens.keys
    end

    private

    def initialize(indexed_tokens)
      @indexed_tokens = indexed_tokens
      @indexes = nil # Shape friendliness
    end
  end
end
