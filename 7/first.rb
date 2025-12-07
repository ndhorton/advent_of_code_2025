# frozen_string_literal: true

# P:
#   Build a working model of a tachyon manifold. Given the manifold data
#   in the input, determine how many times the initial beam is split,
#   or more simply, how many tachyon splitters are activated before all
#   beams reach ground.
#
# Etc:
#
# So we are essentially drawing a graph like thing. This suggests recursion
# as the easiest approach.
# Each function call could take a starting position (and have access to the grid),
# perhaps an instance variable. The function could iterate down through the rows
# until it encounters a tachyon splitter in which case it then does something like
# return 1 + recursive_call + recursive_call
# or it encounters the bottom of the grid, in which case it returns 0
# The problem with this is that some splitters are adjacent enough that
# there is only room for one beam between them.
# This means we could preprocess the grid to designate true splitters and
# half splitters.
# If the function encounters a half splitter it just does
# return 1 + recursive_call
#
# However, the preprocessing would be immensely complicated, because sometimes
# a splitter is a half splitter because an existing split much further up the grid
# created a beam that is now in the way of true splitting.
#
# What you could do is, when the splitter is encountered, for each of the two
# new possible beam starting points, the function checks scans upward from the
# cell where the starting point of the new beam would be. If it encounters a `|`
# character before hitting either the bottom of a tachyon splitter or the top of
# the grid, then no recursive call is made for that position.
# If it doesn't encounter a `|` character, it places one in the starting position
# of the new beam and increments a `new_beams` variable by 1.
# Then it uses that variable to determine how many recursive calls to make.
#
#    row = beam_info[:row]
#    accumulator = 0
#    unless existing_beam?(row, col - 1)
#      p "starting new beam at: (#{row}), #{col - 1})"
#      grid[row][col - 1] = '|'
#      accumulator += count_splits(row, col - 1)
#    end
#    unless existing_beam?(row, col + 1)
#      p "starting new beam at: (#{row}), #{col + 1})"
#      grid[row][col + 1] = '|'
#      accumulator += count_splits(row, col + 1)
#    end
#    1 + accumulator
#
# So, the thing I hadn't accounted for was the order in which the recursive
# calls happen. Essentially, we need to do one row at a time. This is the problem
# with altering the grid as we traverse.
# We could alter one row at a time iteratively rather than using recursion at all.
# We would still use the existing_beam? method.
#
# This doesn't work, since we still need to trace the paths of the beams.
# What might work is using the original recursive pass to mark each splitter
# that gets hit by a beam with an 'x'. The original problem with the recursion
# was that order mattered when counting the number of beams. We were counting some
# twice. But if we do a first recursive pass that simply marks the grid with every
# splitter that gets hit, it doesn't matter the order of the calls.
# Then we do an iterative pass to count the number of splitters that have been marked
# with an 'x'
#
# NB we need to break out of the recursive function if we encounter a splitter
# that has already been marked 'x', otherwise we fall through until we hit
# the next splitter, even if that splitter should be shielded from the beams
# by the splitter above. That was a nasty piece of debugging.
#
# DS:
# We need to modify the grid, so to make the object re-useable we
# could make a copy of the grid as a permanent template and then dup
# it when we run the counting method.
#
# A:
#

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

class TachyonManifold
  def initialize(text)
    @starting_grid = generate_grid(text).freeze
    @grid = nil
  end

  def number_of_splits
    self.grid = starting_grid.dup
    starting_row, starting_col = find_starting_point
    mark_activated_splitters!(starting_row, starting_col)
    count_activated_splitters
  end

  private

  attr_accessor :grid
  attr_reader :starting_grid

  def count_activated_splitters
    grid.reduce(0) do |acc, row|
      acc + row.reduce(0) do |inner_acc, cell|
        cell == 'x' ? inner_acc + 1 : inner_acc
      end
    end
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
    starting_row.upto(grid.size - 1) do |row|
      cell = grid[row][col]
      break if cell == 'x'
      next unless cell == '^'

      # starting_row.upto(row - 1) { |retrace_row| grid[retrace_row][col] = '|' }

      grid[row][col] = 'x'
      mark_activated_splitters!(row, col - 1)
      mark_activated_splitters!(row, col + 1)
      break
    end
  end
end

t = Time.now

input = File.read('input.txt')

puts "Answer: #{TachyonManifold.new(input).number_of_splits}"
puts "Time: #{Time.now - t}"

# Answer: 1690
