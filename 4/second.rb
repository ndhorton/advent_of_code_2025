# frozen_string_literal: true

# P:
#   Count how many rolls have fewer than four neighbours in the eight
#   adjacent positions.
#
# Etc:
#
# We know (and can confirm) that the lines are all 140 chars. This means we could
# look for patterns if we read through the tiles as a flat sequence. I'm not sure
# if that actually helps though (possibly just with optimization and maybe not
# even then).
#
# When we consider the first index we must be careful: an algorithm that
# decrements the indices to check adjacent squares could end up searching
# the end of the array (index -1 etc).
#
# Maybe the easiest approach to start with is to write a function that,
# given a row index and a column index, counts how many rolls are in the
# adjacent 8 tiles.
#
# first, we need a way to determine which offsets are viable.
# Or, we could take the approach of using the safe navigation operator and rely
# on `nil`s to be NOT equal to `'@'`
#
# So we just need a function that takes the list of pair_offsets and iterates through
# testing if each offset pair EXISTS and IF SO whether the offset_pair yields a roll
#
# Ok, so that didn't work quite right.
# We need a function that takes row + row_offset and column + column_offset and:
# * if either value is negative then there is no roll there.
# * if both are positive && @grid[row][column] exists && grid[row][column] == '@'
#   then there is a roll there
# DS:
#
# A:
# * Parse text file into an array of arrays of chars
# * for each row,
# *   for each column
# *     if count_rolls(grid, row, column) < 4
# *       accumulate 1
#

class Parser
  def self.read(filename)
    # rubocop:disable Style/ExpandPathArguments
    root = File.expand_path('..', __FILE__)
    # rubocop:enable Style/ExpandPathArguments
    grid = []
    begin
      file = File.open(File.join(root, filename))
      file.each_line do |line|
        grid << line.chomp.chars
      end
    ensure
      file.close
    end
    grid
  end
end

class RollFinder
  ALL_OFFSETS = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ].freeze

  TOO_MANY_ROLLS = 4

  def initialize(grid)
    @grid = grid
  end

  def count_free_rolls
    result = 0
    loop do
      acc = 0
      @grid.each_index do |row|
        @grid[row].each_index do |column|
          next unless @grid[row][column] == '@' &&
                      count_neighbouring_rolls(row, column) < TOO_MANY_ROLLS

          acc += 1
          @grid[row][column] = 'x'
        end
      end
      break if acc.zero?

      result += acc
    end
    result
  end

  private

  def count_neighbouring_rolls(row, column)
    ALL_OFFSETS.reduce(0) do |acc, (row_offset, column_offset)|
      if roll_at?(row + row_offset, column + column_offset)
        acc + 1
      else
        acc
      end
    end
  end

  def roll_at?(row, column)
    return false if row.negative? || column.negative?

    !!(@grid[row] && @grid[row][column] == '@')
  end
end

test_input = <<~HEREDOC
  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.
HEREDOC
test_input = test_input.split.map(&:chars).freeze

# puts RollFinder.new(test_input).count_free_rolls
puts RollFinder.new(Parser.read('input.txt')).count_free_rolls

# Answer: 1449
