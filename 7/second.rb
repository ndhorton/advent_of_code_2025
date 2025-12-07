# frozen_string_literal: true

# P:
#   Find the number of paths through the graph of activated splitters.
#
# Etc:
#
#  From running a recursive simulation that worked on the test_input on
#  the actual given input, it appears that a recursive solution is out of
#  the question because it will never finish running on such a large input
#  (in Ruby at least).
#  We could try to refactor the recursive solution as an imperative solution,
#  though it is difficult to think of how this could be done.
#  We could try to think of a way to deduce the number of possible paths
#  from the nodes and edges, but even counting the edges would be difficult.
#
#  Or we could reduce the number of times we need to count the paths using
#  memoization.
#
#  If we create a hash where the key is an ordered pair and the value is the
#  number of terminal nodes the node at that point leads to, then we can simply
#  return the value without going back into the iteration to find the same paths
#  again.
#
# DS:
#
# A:
#

class TachyonManifold
  def initialize(text)
    @starting_grid = generate_grid(text).freeze.map { |row| row.map(&:freeze).freeze }
    @memo = {}
    @working_grid = nil
    @timelines = nil
  end

  def number_of_splits
    self.working_grid = deep_copy_starting_grid
    starting_row, starting_col = find_starting_point
    mark_activated_splitters!(starting_row, starting_col)
    count_activated_splitters
  end

  def timelines
    @timelines ||= count_timelines(*find_starting_point)
  end

  private

  attr_accessor :working_grid
  attr_reader :starting_grid, :memo

  def count_activated_splitters
    working_grid.reduce(0) do |acc, row|
      acc + row.reduce(0) do |inner_acc, cell|
        cell == 'x' ? inner_acc + 1 : inner_acc
      end
    end
  end

  def count_timelines(starting_row, col)
    starting_row.upto(starting_grid.size - 1) do |row|
      timelines_remembered = memo[[row, col]]
      return timelines_remembered if timelines_remembered

      next unless starting_grid[row][col] == '^'

      acc = count_timelines(row, col - 1) + count_timelines(row, col + 1)
      memo[[row, col]] = acc
      return acc
    end
    1
  end

  def deep_copy_starting_grid
    starting_grid.dup.map { |row| row.dup.map(&:dup) }
  end

  def find_starting_point
    starting_grid.each_with_index do |row, row_index|
      row.each_with_index do |cell, col_index|
        return [row_index, col_index] if cell == 'S'
      end
    end
  end

  def generate_grid(text)
    text.split("\n").map(&:chars)
  end

  def mark_activated_splitters!(starting_row, col)
    starting_row.upto(working_grid.size - 1) do |row|
      cell = working_grid[row][col]
      break if cell == 'x'
      next unless cell == '^'

      working_grid[row][col] = 'x'
      mark_activated_splitters!(row, col - 1)
      mark_activated_splitters!(row, col + 1)
      break
    end
  end
end

test_input = <<~HEREDOC
  .......S.......
  ...............
  .......^.......
  ...............
  ......^.^......
  ...............
  .....^.^.^.....
  ...............
  ....^.^...^....
  ...............
  ...^.^...^.^...
  ...............
  ..^...^.....^..
  ...............
  .^.^.^.^.^...^.
  ...............
HEREDOC

t = Time.now

input_filename = 'input.txt'
# rubocop:disable Style/ExpandPathArguments
path = File.expand_path('..', __FILE__)
# rubocop:enable Style/ExpandPathArguments
input = File.read(File.join(path, input_filename))

manifold = TachyonManifold.new(input)
puts "Answer: #{manifold.timelines}"
puts "Time: #{Time.now - t}"

# Answer: 221371496188107
