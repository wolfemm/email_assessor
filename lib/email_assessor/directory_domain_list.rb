# frozen_string_literal: true

module EmailAssessor
  class DirectoryDomainList
    attr_reader :pathname

    def include_any?(domain_token_set)
      chars = if @prioritization.present?
        @prioritization
      else
        domain_token_set.indexes
      end

      chars.any? { |char| domain_list(char).include_any?(domain_token_set) }
    end

    def sample
      File.open(Dir.glob(File.join(@pathname, "?.txt")).first, &:readline).chomp
    end

    private

    def initialize(pathname)
      prioritization_file_name = File.join(pathname, "_prioritization.txt")

      @prioritization = File.read(prioritization_file_name).split("").freeze if File.exist?(prioritization_file_name)
      @pathname = pathname
      @file_map = {
        # {first_char} => FileDomainList | nil
      }
    end

    def domain_list(char)
      cached = @file_map[char]

      return cached unless cached.nil?

      file_name = File.join(@pathname, "#{char}.txt")

      domain_list = if File.file?(file_name)
        FileDomainList.new(file_name)
      else
        EmptyDomainList.instance
      end

      @file_map[char] = domain_list

      domain_list
    end
  end
end
