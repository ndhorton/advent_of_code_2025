# frozen_string_literal: true

#
# P:
# Now an invalid ID is any number composed only of repeating digits that repeat
# at least once.
#
# Etc:
# So an invalid ID could be:
# first letter * length of string
# first two letters * (length of string / 2)
# first three letters * (length of string / 3)
# up to...
# first (length of string / 2) letters * (length of string / (length of string / 2))
#
# DS:
#
# A:
#
# invalid_id?(id)
# * Given a string, id
# * maximum = length of id / 2
# * iterate for len from 1..maximum
#   * if a len-length slice of id from index 0, multiplied by the length of the string over len, is equal to the id
#     * return true
# * return false

# Parse CSV file
class Parser
  def self.parse(file)
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

def invalid_id?(id)
  id = id.to_s
  maximum = id.length / 2
  1.upto(maximum) do |len|
    current_slice = id.slice(0, len)
    candidate = current_slice * (id.length / len)
    return true if candidate == id
  end
  false
end

ranges = Parser.parse('input.txt')
acc = 0
ranges.each do |current_range|
  current_range.each do |id|
    acc += id if invalid_id?(id)
  end
end

puts acc

# answer: 21932258645
