# frozen_string_literal: true

#
# P:
#   For each row of batteries in the input, you need to switch on the two
#   batteries that combine to produce the highest joltage output.
#   Each battery is labelled with a number. The numbers combine simply as
#   digits in a two-digit number. The order is fixed, so that the first battery
#   in the row is the leading digit (tens digit) and the next is the low digit (ones).
#
# Etc:
#
# So if the row is 1234, the highest joltage is 34.
# Each bank of batteries looks to be 100 batteries long. There are banks (rows).
# One approach might be to convert each battery to a number that represents not
# only its value but potential magnitude in the final digit-concatenation.
# So 1 -> 10
#    2 -> 20
#    3 -> 30
#    4 -> 4
# We then get the max by the value part, which is 30. We then simply get the max
# from the remaining digits, which in this case just leaves 4.
#
# DS:
# Struct Battery
# - label
# - joltage
#
# A:
#
# * Parse the input into array of banks of Battery objects.
# * total_joltage = 0
# * for each bank in banks
#   * first_index = find index of the maximum battery in bank by joltage
#   * pair = empty array containing bank[first_index]
#   * second_index = in bank[first_index + 1 onwards], find index of maximum battery by label
#   * push to pair bank[second_index]
#   * convert pair to their label value and join into joltage_value
#   * total_joltage += joltage_value

# Encapsulate Battery label and its potential joltage
Battery = Struct.new('Battery', :label, :joltage)

# Parse input file an array of rows, each row an array of chars
# Rows are banks, chars are batteries
class Parser
  class << self
    def read(filename)
      # rubocop:disable Style/ExpandPathArguments
      file_path = File.join(File.expand_path('..', __FILE__), filename)
      # rubocop:enable Style/ExpandPathArguments
      begin
        file = File.open(file_path)
        extract_battery_banks(file)
      ensure
        file.close
      end
    end

    private

    def extract_battery_banks(file)
      file.each_line.map { |line| extract_bank(line) }
    end

    def extract_bank(line)
      row = line.chomp.chars
      last_label = row.pop.to_i
      bank = row.map do |char|
        label = char.to_i
        Battery.new(label, label * 10)
      end
      bank << Battery.new(last_label, last_label)
    end
  end
end

t = Time.now

banks = Parser.read('input')

total_joltage = banks.reduce(0) do |acc, bank|
  first_index = bank.index(bank.max_by(&:joltage))
  pair = [bank[first_index].joltage]
  remaining_bank = bank[first_index + 1..]
  second_index = remaining_bank.index(remaining_bank.max_by(&:label))
  pair << remaining_bank[second_index].label
  acc + pair.sum
end

puts "Answer: #{total_joltage}"
puts "Time: #{Time.now - t} seconds"

# answer: 17343
