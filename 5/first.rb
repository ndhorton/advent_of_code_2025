# frozen_string_literal: true

# P:
#
# Given a list of Fresh ID integer ranges and a list of integer Ingredient IDs,
# determine how many Ingredient IDs are contained in the ranges and thus are fresh
# ingredients.
#
# Etc:
#
# The simplest way to do this would be to iterate through each ID and pass it to
# a function that iterates through each of the ranges. If the ID is covered by the
# range, the function returns true. Otherwise, at the end of the function, we return
# false. If the function returns true, the accumulator is incremented.
#
# This means, however, that we need to iterate 186 times for each of the 1000 IDs.
# This might be feasible, but does not scale.
#
# DS:
#
# A:
#

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
    def count_fresh_ingredients(ingredients)
      ingredients.ids.reduce(0) do |acc, id|
        fresh_id?(ingredients, id) ? acc + 1 : acc
      end
    end

    private

    def fresh_id?(ingredients, id)
      ingredients.ranges.each { |range| return true if range.cover?(id) }
      false
    end
  end
end

t = Time.now
ingredients = Ingredients.new('input.txt')
answer = FreshFinder.count_fresh_ingredients(ingredients)
puts "Answer: #{answer}"
puts "Time #{Time.now - t}"

# Answer: 865
