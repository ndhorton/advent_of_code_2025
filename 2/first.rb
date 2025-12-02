# frozen_string_literal: true

# P:
# For each range of IDs given in the csv file, find every invalid ID.
# We then sum all the invalid IDs to find the answer.
# An invalid ID:
# * consists only of some sequence of digits repeated twice.
#
# Etc:
# from the examples, it looks like we are essentially splitting each ID
# in half and if the first half is the same as the second then it is invalid.
#
# DS:
#
# A:
# * parse the csv into an array of Range objects
# * iterate through the array of ranges
#   * iterate through each number in the current range
#     * convert current number to number_string
#     * split number_string in half
#     * if the first half is the same as the second
#       * add the number to the accumulator

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

ranges = Parser.parse('input.txt')
result = ranges.reduce(0) do |outer_acc, range|
  outer_acc + range.reduce(0) do |inner_acc, number|
    number_string = number.to_s
    next inner_acc if number_string.length.odd?

    middle = number_string.size / 2
    first_half = number_string[0...middle]
    second_half = number_string[middle..]
    if first_half == second_half
      inner_acc + number
    else
      inner_acc
    end
  end
end
puts result

# answer: 19128774598
