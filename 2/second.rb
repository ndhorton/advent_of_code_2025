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
# So brute force is easy.
#
# Procedural solution.
# We can easily generate the possible valid chunk sizes for a given ID.
# We can't have a chunk as big as the number, since it has to repeat.
# So, starting at 2, we divide the digit count of the ID by each number until we
# get to the digit count itself. If the remainder is 0, then the resulting factor
# can be added to the set of possible chunk sizes.
# E.g., for a 9-digit ID,
# 9 % 2 != 0
# 9 % 3 == 0. So we add the result of 9 / 3 (3) to the chunk-size set
# 9 % 4 != 0
# ...
# 9 % 9 == 0, so we add 9 / 9 == 1 to the chunk-size set,
# which is { 1, 3 }. These are the sizes of chunk that can be repeated to compose
# the ID exactly.
#
# These chunk-size sets could be memoized for added efficiency, so that each time
# our program encounters a new digit-count, we check a hash to see if we can simply
# extract the chunk-size set rather than calculate it again.
#
# For any given range, we could convert the lowest number to its digit size and
# do the same for the highest number. Then we need to procedurally generate every
# combination of repeating chunks that can exist within the range
#
# E.g., 11-22
# So the only chunk size feasible is 1, since the entire range is 2-digit.
# Also, the description tells us that *no ID starts with zero.
# So the first possible repeat chunk is `1`, forming `11`.
# The second is `2` forming `22`.
# We can't go any further without exceeding the range.
#
# Another example. 998-1012. The possible chunk sizes are { 1 } for 3 digits
# and then { 1, 2 } for 4 digits.
# How do we know where to start?
# We don't want to generate `111` through `888` do we? We could, and simply test against
# the lowest bound. But it might make sense to go the other way.
# Also, it occurs to me that we should pair a chunk size with the number of
# repeats needed to fill the digit-count when we memoize it. Anyway,
#
# "9" * 3 == "999". 999 is greater than the lowest bound and smaller than the highest.
# We add that to the solution set for this range.
# "8" * 3 == "888". 888 is lower than the lowest bound. Stop. But how do we know to stop?
# Since when we come to the 4-digit solutions, we need to start from the bottom and
# stop when they get too big. So we could say that we start from the top when
# we are in the digit-count that contains the low bound. Any intermediate digit-counts
# it doesn't matter, and then we start from the bottom when we get to the maximum
# digit count.
#
# So for 4 digits, this is the size of the upper bound, so we start from the bottom.
# The chunk sizes are 1 and 2.
# "1" * 4 == "1111". 1111 is already higher than the bound so we stop
# "10" * 2 == "1010". (first digit cannot be 0). 1010 is lower than high bound, so we
# add it to the solution set.
# "11" * 2 == "1111". 1111 is higher than the bound, so stop.
# Therefore, the solution set for this range is { 999, 1010 }.
#
# E.g, 1,188,511,880 - 1,188,511,890
# The range is 10 digit-count numbers only.
# 10 % 2 == 0. 10 / 2 == 5.
# 10 % 5 == 0. 10 / 5 == 2.
# 10 % 10 == 0. 10 / 10 == 1. So the set of chunk sizes is { 1, 2, 5 }
# So, start with `1` * 10. too low
# `2` * 10. too high. Move on to 2-digit chunks
# `10` * 5 == 1010101010. too low.
# `11` * 5 == 1111111111. too low
# `12` * 5 == 1212121212. too high. next chunk size
# `10000` * 2 == 1000010000. too low
# ...
# `11885` * 2 == 1188511885. not too high or low. add to set
# `11886` * 2 == 1188611886. too high. Stop
#
# Actually, the starting point should not be `10`, `100` etc.
# The starting point should be the first n digits of the low bound. We should
# stop when we exceed the high bound.
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

# Brute force

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

t = Time.now
ranges = Parser.read('input.txt')
acc = 0
ranges.each do |current_range|
  current_range.each do |id|
    acc += id if invalid_id?(id)
  end
end

puts "Anser: #{acc}"
puts "Time: #{Time.now - t}"

# answer: 21932258645
