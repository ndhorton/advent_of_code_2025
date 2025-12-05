# frozen_string_literal: true

# P:
#
# Given a list of Fresh ID integer ranges, determine how many Ingredient IDs
# in total are contained in the ranges.
#
# Etc:
#
# Essentially, we need to count ONLY ONCE every number covered by the ranges.
# Since the ranges can overlap, this cannot be done in a brute force manner.
#
# The most obvious strategy would be to join all the overlapping ranges
# so that we are left with ranges whose collective members are all unique
# in the collection of ranges.
#
# There are 186 ranges in the input file. If we check each range against every
# other range, this is 186 ** 2 == 34596 checks.
#
# However, it is more complicated than this.
#
# Once we join two ranges, the original two need to be removed from
# consideration. We essentially need to find all ranges that overlap the
# first range, remove them and the first range from the collection,
# join them, and then place the joined range back in the collection.
#
# So we could remove the first, destructively filter for overlapping ranges,
# create a new range whose starting point is the lowest value in the removed
# ranges and whose upper bound is the highest value in the removed ranges.
#
# What we could do is sort the ranges by lowest member initially.
# Then we know that if the range does not overlap its immediate neighbour,
# it won't overlap any neighbours farther down the array.
# Then we chunk the ranges while they overlap, merge any chunk that contains
# more than one range. I don't foresee having to do more than one chunking,
# but if we have to do repeat passes until there are no merges, we could count
# each merge operation and stop when that variable is 0 at the end of the loop.
#
# One thing that threw me is that it is vitally important to sort the ranges
# by [range.first, range.last], not just the first member.
#
#
# If we only sort by the first member, depending on the vicissitudes of the Ruby
# sort and sort_by algorithms (which are different, sort does not guarentee order
# whereas sort_by does), we might end up with
# [1..10, 1..3], or [1..3, 1..10]. But in addition to this, I was using Range#overlap?
# with the chunk_while algorithm, and obviously the order matters when considering
# whether a range overlaps the next. [1..3, 1..10, 7..14] will get grouped as one
# chunk, whereas [1..10, 1..3, 7..14] will get grouped as [1..10, 1..3] and [7..14].
# This means that not all overlapping ranges get merged, and the answer when
# we count the members of all merged ranges comes out too high, because some numbers
# get counted twice.
#
# I actually got the right result through with the flawed implementation
# (`sort { |a, b| a.first <=> b.first }`) through the luck of the `sort` algorithm
# before I realized why this was different from my initial `sort_by(&:first)`.
# I then had to work backwards to understand why I was getting two different answers
# from the `sort` and `sort_by` even though the two calls seemed functionally
# equivalent (if order is important they are not).
#
#
# I needed to use `min_by(&:first)` and `max_by(&:last)` in the
# `merge_ranges` function, because even when explicitly sorted by
# `[range.first, range.last]`, the highest member will only come into play
# when the first members are the same. So, `1...900` comes before `2..3`.
#
# A:

# Parse and store ranges and ids from filename
class Ingredients
  attr_reader :ranges, :ids

  def initialize(filename)
    @ranges, @ids = partition_ranges_and_ids(readlines(filename))
  end

  private

  def readlines(filename)
    # rubocop:disable Style/ExpandPathArguments
    path = File.expand_path('..', __FILE__)
    # rubocop:enable Style/ExpandPathArguments
    file_path = File.join(path, filename)
    File.readlines(file_path)
  end

  def process_range(line)
    bounds = line.chomp.split('-')
    (bounds.first.to_i..bounds.last.to_i)
  end

  def partition_ranges_and_ids(lines)
    i = 0
    ranges = []
    ids = []
    while lines[i] != "\n"
      ranges << process_range(lines[i])
      i += 1
    end
    (i + 1...lines.size).each { |index| ids << lines[index].chomp.to_i }
    [ranges, ids]
  end
end

# Find the number of fresh ingredients
class FreshFinder
  class << self
    def count_fresh_ingredient_ids(ingredients)
      ingredients.ids.reduce(0) do |acc, id|
        fresh_id?(ingredients, id) ? acc + 1 : acc
      end
    end

    def count_total_fresh_ingredients(ingredients)
      ranges = sort_ranges(ingredients.ranges)
      chunks = ranges.chunk_while { |a, b| a.overlap? b }
      non_overlapping_ranges = chunks.each_with_object([]) do |chunk, arr|
        arr << merge_ranges(chunk)
      end
      non_overlapping_ranges.reduce(0) { |acc, range| acc + range.size }
    end

    private

    def fresh_id?(ingredients, id)
      ingredients.ranges.each { |range| return true if range.cover?(id) }
      false
    end

    def merge_ranges(ranges)
      ranges.min_by(&:first).first..ranges.max_by(&:last).last
    end

    def sort_ranges(ranges)
      ranges.sort do |a, b|
        [a.first, a.last] <=> [b.first, b.last]
      end
    end
  end
end

# First part
t = Time.now
ingredients = Ingredients.new('input.txt')
answer = FreshFinder.count_fresh_ingredient_ids(ingredients)
puts "Answer: #{answer == 865}"
puts "Time #{Time.now - t}"

# Answer: 865

# Second part
t = Time.now
ingredients = Ingredients.new('input.txt')
answer = FreshFinder.count_total_fresh_ingredients(ingredients)
puts "Answer: #{answer == 352_556_672_963_116}"
puts "Time #{Time.now - t}"

# Answer: 352556672963116
