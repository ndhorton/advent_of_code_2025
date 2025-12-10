# frozen_string_literal: true

# P:
#
# Etc:
#
# One approach is to try and devise a method for determining if a given
# tile is within the perimeter.
#
# The sequence of ordered pairs in the special order in which they are given
# describes a sequence of straight lines.
#
# The rectangle must have red tiles in opposite corners.
#   This suggests that at least two of its sides must be contained as three
#    entries in the sequence of ordered pairs.
#   So if we iterate through three at a time and get the area, the largest
#   area might be the answer. If this doesn't work, maybe I can think of a
#   counterexample where this doesn't work. It probabaly won't work, it seems
#   too easy.
#
# ..............
# .......#XXX#..
# .......X...X..
# ..#XXXX#...X..
# ..X........X..
# ..#........X..
# ..X........X..
# ..#XXXXXX#X#..
# ..............
#
#  Yeah, all that needs to happen is that two vertices are in a straight line.
#  Of course, we could simply check for this. But how does that help us?
#  How would we know whether an area is valid if we cannot check if the tiles
#  that compose it are valid red/green?
#
# DS:
#
# A:
#

require 'set'

RedTile = Struct.new('RedTile', :x, :y)

def line_length(coord1, coord2)
  ((coord2 - coord1).abs + 1)
end

def red_tiles_from_text(text)
  text.split("\n").map { |line| RedTile.new(*line.split(',').map(&:to_i)) }
end

def red_tiles_from_file(filename)
  # rubocop:disable Style/ExpandPathArguments
  path = File.expand_path('..', __FILE__)
  # rubocop:enable Style/ExpandPathArguments
  file_path = File.join(path, filename)
  red_tiles_from_text(File.read(file_path))
end

test_input = <<~HEREDOC
  7,1
  11,1
  11,7
  9,7
  9,5
  2,5
  2,3
  7,3
HEREDOC

t = Time.now

# red_tiles = red_tiles_from_text(test_input)
red_tiles = red_tiles_from_file('input.txt')
red_tiles += red_tiles.take(2)
RED_TILES = Set.new(red_tiles.map { |tile| [tile.x, tile.y] })

# Check whether 2 of 3 tile tiles share an x
def exactly_two_x?(tile1, tile2, tile3)
  [tile1.x, tile2.x, tile3.x].uniq.size == 2
end

# Check whether 2 of 3 tile tiles share a y
def exactly_two_y?(tile1, tile2, tile3)
  [tile1.y, tile2.y, tile3.y].uniq.size == 2
end

def describe_perpendicular_lines?(tile1, tile2, tile3)
  exactly_two_x?(tile1, tile2, tile3) && exactly_two_y?(tile1, tile2, tile3)
end

def opposite_corners(tile1, tile2, tile3)
  [tile1, tile2, tile3].combination(2).select do |a, b|
    a.x != b.x && a.y != b.y
  end.first
end

# Defines an inclusive range of tiles to search horizontally
def start_and_stop_x(corner1, corner2)
  min_x, max_x = [corner1.x, corner2.x].minmax
  min_x += 2
  max_x -= 2
  [min_x, max_x]
end

# Defines an inclusive range of tiles to search vertically
def start_and_stop_y(corner1, corner2)
  min_y, max_y = [corner1.y, corner2.y].minmax
  min_y += 2
  max_y -= 2
  [min_y, max_y]
end

def valid_rectangle?(corner1, corner2)
  start_x, stop_x = start_and_stop_x(corner1, corner2)
  start_y, stop_y = start_and_stop_y(corner1, corner2)
  start_y.upto(stop_y) do |y|
    start_x.upto(stop_x) do |x|
      return false if RED_TILES.member?([x, y])
    end
  end
  true
end

def area(corner1, corner2)
  side_length(corner1.x, corner2.x) * side_length(corner1.y, corner2.y)
end

def side_length(first, second)
  ((second - first).abs + 1)
end

max = 0
red_tiles.each_cons(3) do |tile1, tile2, tile3|
  # We need to determine whether these vertices describe perpendicular lines
  #   We already know that they all follow on from each other, so we need to
  #   check that ONLY two share an x OR ONLY two share a y
  #   because if they ALL share an x or ALL share a y then they describe a
  #   single line
  # If they do not describe perpendicular lines
  #   next iteration

  # next unless describe_perpendicular_lines?(tile1, tile2, tile3)

  # Having established that, we need to find the opposite corners
  # The opposite corner tiles will have a different x and different y
  corner1, corner2 = opposite_corners(tile1, tile2, tile3)

  # Now we know that the tiles between the two overlapping pairs of known
  # red tiles will be green tiles, along the two known lines.
  # And if a red tile occurs on the two imaginary lines, I don't THINK that
  # can prevent a valid rectangle. I think a valid rectangle can only be
  # prevented when there is a red tile inside the imaginary perimeter of the
  # rectangle. So we need to scan through the tiles INSIDE the imaginary
  # rectangle perimeter to check that there are no red tiles.
  # If there aren't, then we take the area

  rectangle_area = area(corner1, corner2)
  max = rectangle_area if rectangle_area > max
  #   if valid_rectangle?(corner1, corner2)
  #     rectangle_area = area(corner1, corner2)
  #     max = rectangle_area if rectangle_area > max
  #   end
end

puts max
puts "Time: #{Time.now - t}"
