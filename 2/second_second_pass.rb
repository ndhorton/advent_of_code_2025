# frozen_string_literal: true

# Parse CSV file
class Parser
  def self.read(file)
    # rubocop:disable Style/ExpandPathArguments
    root = File.expand_path('..', __FILE__)
    # rubocop:enable Style/ExpandPathArguments
    input_text = File.read(File.join(root, file))
    range_strings = input_text.split(',')
    range_strings.map do |range_string|
      range_values = range_string.split('-').map(&:to_i)
      (range_values.first..range_values.last)
    end
  end
end

# Generate the answer
class InvalidIDGenerator
  class << self
    # Encapsulate information about a chunk and the digit-length range it applies to
    ChunkInfo = Struct.new('ChunkInfo',
                           :lowest, :highest, :repeats, :range)

    def sum_invalid_ids(file)
      ranges = Parser.read(file)
      solution_set = ranges.each_with_object(Set.new) do |range, set|
        set.merge invalid_ids(range)
      end
      solution_set.sum
    end

    private

    def invalid_ids(range)
      length_ranges = get_length_ranges(range)
      length_ranges.each_with_object(Set.new) do |length_range, set|
        set.merge invalid_ids_from_length_range(length_range)
      end
    end

    def invalid_ids_from_length_range(length_range)
      chunk_sizes = get_chunk_sizes(length_range)
      chunk_infos = get_chunk_infos(chunk_sizes, length_range)
      chunk_infos.each_with_object(Set.new) do |chunk_info, set|
        set.merge invalid_ids_from_chunk_info(chunk_info)
      end
    end

    def invalid_ids_from_chunk_info(chunk_info)
      chunk_range = (chunk_info.lowest..chunk_info.highest)
      chunk_range.each_with_object(Set.new) do |current_chunk, set|
        if invalid_id?(current_chunk, chunk_info)
          invalid_id = (current_chunk.to_s * chunk_info.repeats).to_i
          set.add invalid_id
        end
      end
    end

    # Get chunk info from a digit-length range and the set of possible chunk sizes
    def get_chunk_infos(chunk_size_set, length_range)
      digits = length_range.first.to_s.size
      chunk_size_set.map do |chunk_size|
        ChunkInfo.new(
          length_range.first.to_s[0, chunk_size].to_i,
          length_range.last.to_s[0, chunk_size].to_i,
          digits / chunk_size,
          length_range
        )
      end
    end

    def get_chunk_sizes(length_range)
      digits = length_range.first.to_s.size
      (2..digits).each_with_object([]) do |len, arr|
        arr << (digits / len) if (digits % len).zero?
      end
    end

    def get_length_ranges(range)
      digit_counts = (range.first.to_s.length..range.last.to_s.length)
      digit_counts.map do |count|
        if count == digit_counts.first
          first_length_range(count, range)
        elsif count == digit_counts.last
          last_length_range(count, range)
        else
          middle_length_range(count)
        end
      end
    end

    def first_length_range(count, range)
      (range.first..(count == range.last.to_s.size ? range.last : ('9' * count).to_i))
    end

    def last_length_range(count, range)
      "1#{'0' * (count - 1)}".to_i..range.last
    end

    def middle_length_range(count)
      "1#{'0' * (count - 1)}".to_i..('9' * count).to_i
    end

    def invalid_id?(current_chunk, chunk_info)
      chunk_info.range.cover? (current_chunk.to_s * chunk_info.repeats).to_i
    end
  end
end

t = Time.now
puts "Answer: #{InvalidIDGenerator.sum_invalid_ids('input.txt')}"
puts "Time: #{Time.now - t}"

# Answer: 21932258645
