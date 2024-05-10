# frozen_string_literal: true

module EmailAssessor
  class EmptyDomainList
    class << self
      def instance
        @instance ||= new
      end
    end

    def include_any?(*)
      false
    end

    def sample
      nil
    end

    def pathname
      nil
    end
  end
end
