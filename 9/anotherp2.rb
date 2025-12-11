# frozen_string_literal: true

# P:
#   Given a list of tile coordinates of the form (x, y), where x and y
#   begin at 0, and each tile has an area of 1 units squared, find the
#   largest area of a rectangle formed with two ordered pairs each denoting
#   a tile at the diagonally-opposite corner from the other.
#
# Etc:
#   Essentially we want the minimum tile and the maximum tile where the minimum
#   is the closest to the origin tile (0, 0) and the maximum tile is furthest
#   away in both x and y directions.
#
#   With the short test input list, we have 8 ordered pairs and we choose two,
#   where order of the two pairs is not important. So (8 choose 2) is 28
#   combinations.
#
#   So we could use the basic combination algorithm for such a small dataset
#   with no problems. And the same hold true for the real input, which is
#   only 496 pairs. (496 choose 2) is 122760 combinations, which would take
#   a while but is ok for now.
#
#   The area formula is (|X1 - X2| + 1) * (|Y1 - Y2| + 1). So we need a function
#   that computes this, given two ordered pairs. And we need a class/struct/hash
#   that represents an ordered pair.
#
#  Another approach might be to find the red tile with the lowest x value with the
#  lowest y value (so we could simply look for the min value of x + y) and the
#  tile with the lowest x value that has the highest y value (not sure how to look
#  for that). Then we find the tile with the highest x + y, then the tile with the
#  highest x value and the lowest y value (not sure how to look for that).
#
#  So
#  lowest x, lowest y -- top-left
#  lowest x, highest y -- bottom-left
#  highest x, lowest y -- top-right
#  highest x, highest y -- bottom-right
#
#  and they pair (top-left, bottom-right), (bottom-right, top-left)
#
#  lowest x, lowest y == lowest (x + y)
#  highest x, highest y == highest (x + y)
#  lowest x, highest y == find maximum (y - x)
#  highest x, lowest y == find maximum (x - y)
#
#  We can now try applying this approach to the second part.
#
#  We need a list of candidates for each corner because many of them might
#  be invalid.
#
#  But there is a further problem, how do we combine the corners?
#
# first top-left candidate
#   keep trying bottom-right candidates in order until we find valid_rectangle
# first bottom-right candidate
#   keep trying top-left candidates in order until we find valid_rectangle
# then repeat for the other opposite-corners
#
# The problem is that the valid_rectangle? method takes forever on the largest
# rectangles.
#
# What we need to do is use ranges formed by the rectangle corners we are testing
# and then iterate through the list of red tiles to check if their x and y values
# fall within that range.
#
# This whole approach of checking for red tiles inside the perimeter of the
# rectangle is insufficient to eliminate certain types of invalid rectangle.
# For instance, running it on the test input permits (2, 3) and (9, 7),
# since they produce a rectangle with no red tiles inside its perimeter. However,
# a red tile on the perimeter changes the direction of the overall shape's perimeter,
# meaning that not all tiles are within the shape's perimeter.
#
# One approach might be to follow the red tiles adjacent to the known corners.
# If at any point a red tile on the perimeter 'points' to a new line that
# eats into the ranges of tiles within the current rectangle's perimeter, then
# we reject the rectangle.
# so if we find the index of one of the corners and look at the two
# adjacent tiles in both directions in the list of tiles, we could form some
# lines and then check whether each tile in the lines encroaches into the
# problematic ranges.
#
# Doesn't work.
#
# One approach that might work is, for every three consecutive tiles
# find the minimum area that they cover and express it as a valid range
# DS:
#
# A:

OrderedPair = Struct.new('OrderedPair', :x, :y)

def extract_pairs_from_file(filename)
  # rubocop:disable Style/ExpandPathArguments
  path = File.expand_path('..', __FILE__)
  # rubocop:enable Style/ExpandPathArguments
  text = File.read(File.join(path, filename))
  extract_pairs_from_text(text)
end

def extract_pairs_from_text(text)
  text.split("\n").map { |line| OrderedPair.new(*line.split(',').map(&:to_i)) }
end

def rectangle_area(pair1, pair2)
  ((pair2.x - pair1.x).abs + 1) * ((pair2.y - pair1.y).abs + 1)
end

# Defines an inclusive range of tiles to search horizontally
def start_and_stop_x(corner1, corner2)
  min_x, max_x = [corner1.x, corner2.x].minmax
  min_x += 1
  max_x -= 1
  (min_x..max_x)
end

# Defines an inclusive range of tiles to search vertically
def start_and_stop_y(corner1, corner2)
  min_y, max_y = [corner1.y, corner2.y].minmax
  min_y += 1
  max_y -= 1
  (min_y..max_y)
end

def valid_tile?(tile, bad_x_range, bad_y_range)
  !(bad_x_range.cover?(tile.x) && bad_y_range.cover?(tile.y))
end

def valid_area?(tiles, bad_x_range, bad_y_range)
  tiles.each do |tile|
    return false unless valid_tile?(tile, bad_x_range, bad_y_range)
  end
  true
end

def get_corner_tiles(central_tile, red_tiles)
  central_tile_index = red_tiles.index(central_tile)
  [

    red_tiles[central_tile_index - 2],
    red_tiles[central_tile_index - 1],
    red_tiles[central_tile_index],
    red_tiles[(central_tile_index + 1) % red_tiles.size],
    red_tiles[(central_tile_index + 2) % red_tiles.size]
  ]
end

def valid_line?(line, bad_x_range, bad_y_range)
  line.each do |tile|
    return false unless valid_tile?(tile, bad_x_range, bad_y_range)
  end
  true
end

def construct_line(tile1, tile2)
  if tile1.x == tile2.x
    min_y, max_y = [tile1.y, tile2.y].minmax
    (min_y..max_y).map { |y| OrderedPair.new(tile1.x, y) }
  else
    min_x, max_x = [tile1.x, tile2.x].minmax
    (min_x..max_x).map { |x| OrderedPair.new(x, tile1.y) }
  end
end

def valid_lines?(central_tile, red_tiles, bad_x_range, bad_y_range)
  get_corner_tiles(central_tile, red_tiles).each_cons(2) do |tile1, tile2|
    line = construct_line(tile1, tile2)
    return false unless valid_line?(line, bad_x_range, bad_y_range)
  end
  true
end

def valid_rectangle?(corner1, corner2, red_tiles)
  bad_x_range = start_and_stop_x(corner1, corner2)
  bad_y_range = start_and_stop_y(corner1, corner2)
  return false unless valid_area?(red_tiles, bad_x_range, bad_y_range)

  valid_lines?(corner1, red_tiles, bad_x_range, bad_y_range) &&
    valid_lines?(corner2, red_tiles, bad_x_range, bad_y_range)
end

def area_info(corner1, corner2)
  {
    pair: "(#{corner1.x},#{corner1.y}) and (#{corner2.x},#{corner2.y})",
    area: rectangle_area(corner1, corner2)
  }
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

pairs = extract_pairs_from_file('input.txt')
# pairs = extract_pairs_from_text(test_input)

def perpendicular?(tiles)
  return false if tiles.size != 3

  tiles.combination(2).one? do |tile1, tile2|
    tile1.x == tile2.x && tile1.y != tile2.y
  end &&
    tiles.combination(2).one? do |tile1, tile2|
      tile1.y == tile2.y && tile1.x != tile2.x
    end &&
    tiles.combination(2).one? do |tile1, tile2|
      tile1.y != tile2.y && tile1.x != tile2.x
    end &&
    tiles.combination(2).none? do |tile1, tile2|
      tile1.x == tile2.x && tile1.y == tile2.y
    end
end

(pairs + pairs.take(2)).each_cons(3) do |tiles|
  p tiles unless perpendicular?(tiles)
end

# top_lefts = pairs.sort_by { |pair| pair.x + pair.y }
# bottom_rights = pairs.sort { |a, b| b.x + b.y <=> a.x + a.y }
# top_rights = pairs.sort { |a, b| b.x - b.y <=> a.x - a.y }
# bottom_lefts = pairs.sort { |a, b| b.y - b.x <=> a.y - a.x }
#
# areas = []
#
# top_left = top_lefts.first
# bottom_rights.each do |bottom_right|
#   if valid_rectangle?(top_left, bottom_right, pairs)
#     areas << area_info(top_left, bottom_right)
#     break
#   end
# end
#
# bottom_right = bottom_rights.first
# top_lefts.each do |top_left|
#   if valid_rectangle?(top_left, bottom_right, pairs)
#     areas << area_info(top_left, bottom_right)
#     break
#   end
# end
#
# top_right = top_rights.first
# bottom_lefts.each do |bottom_left|
#   if valid_rectangle?(top_right, bottom_left, pairs)
#     areas << area_info(top_right, bottom_left)
#     break
#   end
# end
#
# bottom_left = bottom_lefts.first
# top_rights.each do |top_right|
#   if valid_rectangle?(top_right, bottom_left, pairs)
#     areas << area_info(top_right, bottom_left)
#     break
#   end
# end
#
# maximum = areas.max_by { |area_information| area_information[:area] }
# answer = maximum[:area]
# puts "Maximum rectangle corners: #{maximum[:pair]}"
# puts "Answer: #{answer}"
# puts "Time: #{Time.now - t}"
