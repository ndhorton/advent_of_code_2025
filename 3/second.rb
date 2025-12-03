# frozen_string_literal: true

# P:
#  This time we need to select the twelve batteries in a bank that
#  combine in left-to-right order to form the highest joltage.
#
# Etc:
# Last time, we only needed to consider one change in the magnitude
# depending on order, now we need to consider 11 changes.
# We could create some kind of hash-like object for the joltage property.
# On first pick, we can consider bank[0..-13]
# next pick, we can consider bank[first_index..-12]
# and so on
#
# let's say three instead of twelve for a moment.
#
# 832827192783
#
# on the first iteration, we can consider
# 8328271927 -> max is 9
# on the next iteration, we can consider
# 278 -> max is 8
# on the next iteration, we can consider
# 3 -> max is 3
# So the max joltage for this bank is 983
#
# But how do we occlude the parts of the array that should not be searched?
#
# DS:
#
# A:
#

TOTAL_BATTERIES = 12
INPUT_FILENAME = 'input'

def highest_joltage(bank)
  joltage = []
  leading_index = 0
  last_index = bank.size - TOTAL_BATTERIES
  TOTAL_BATTERIES.times do
    max, leading_index = max_with_leading_index(bank, leading_index, last_index)
    last_index += 1
    joltage << max
  end
  joltage.join.to_i
end

def make_bank(string)
  string.chomp.chars
end

def max_with_leading_index(bank, leading_index, last_index)
  max = ' '
  index = leading_index
  while index <= last_index
    if bank[index] > max
      max = bank[index]
      leading_index = index + 1
    end
    index += 1
  end
  [max, leading_index]
end

t = Time.now
acc = 0
begin
  # rubocop:disable Style/ExpandPathArguments
  file = File.open(File.join(File.expand_path('..', __FILE__), INPUT_FILENAME))
  # rubocop:enable Style/ExpandPathArguments
  file.each_line do |line|
    acc += highest_joltage(make_bank(line))
  end
ensure
  file.close
end

puts "Answer: #{acc}"
puts "Time: #{Time.now - t}"

# Answer: 172664333119298
