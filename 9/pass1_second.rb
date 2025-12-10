# frozen_string_literal: true

# P:
#   The area of potential rectangles is now constrained to the area formed
#   by drawing edges from each red tile to another. The only tiles that can
#   be included in the max area rectangle must be within the perimeter formed
#   by connecting the red tiles. So we need to find the largest rectangle whose
#   diagonally-opposite corners are part of the perimeter-area.
#
# Etc:
#
#   We could try to procedurally generate a map like the one given in the examples.
#   This would be stored as an array of arrays of chars.
#   We could then try the rectangles in the list sorted in descending area order.
#   For each pair of ordered pairs, we could extract the rectangle from the map
#   and check that it contains only `#` and `X` chars.
#   This would be very slow and memory-itensive, but might work.
#
#   But actually, we do know that every red tile ('#') in the list is connected to the
#   tiles before and after it in a straight line of green tiles ('X'). This means
#   we could
#   * first create the tile_map structure using the max_x and max_y as sizes.
#   * iterate over the pairs in twos, pair1 and pair2 (each_cons)
#     * draw in the '#' chars in the tile_map at pair1 and pair2
#     * we are dealing with straight lines between each of these pairs,
#       so either the x differs or the y differs,
#       therefore we iterate between the pairs either up or across drawing in 'X' chars
#   * We need to remember to deal with the connection between pairs[0] and pairs[-1]
#   * iterate through each y
#     * set pencil_down = false
#     * iterate through each x
#       * if tile_map[y][x] == '#' || tile_map[y][x] == 'X'
#         * pencil_down = !pencil_down
#         * next iteration
#       * if pencil_down
#         * tile_map[y][x] = 'X'
#
# The only viable rectangles are formed by red tiles.
# The x and y of the first red tile must BOTH be smaller than the x and y of the
# second red tile.
#
# This doesn't work because the input would generate a tile map of 100,000 x 100,000
# and attempting to create a nested array this large takes forever.
#
# So, the question essentially becomes: how do we tell if a tile is within the
# perimeter?
#
# A tile is within the perimeter if
# 1) The tile is a red tile
# 2) There is a red tile whose x position is <= the tile's x position AND
#      there is a red tile whose x position is >= the tile's x position AND
#      there is a red tile whose y position is <= the tile's y position AND
#      there is a red tile whose y position is >= the tile's y position AND
#      what? Because the above conditions don't always work
# DS:
#
# A:
# * set max_x := find the ord_pair with the largest x value, get the x value
# * set max_y := find the ord_pair with the largest y value, get the y value
# * create map, max_y-sized array of max_x-sized arrays whose every element value is '.'
# Remember we need to deal with the pair formed by ordered_pairs.first and ordered_pairs.last as well as the consecutive pairs
# We know that each consecutive pair forms a straight line
# If the x values are the same, we need to draw a line vertically
# If the y values are the same, we need to draw a line horizontally
# * iterate through each consecutive pair a,b of ordered pairs
#   * if a.x == b.x
#     * draw_vertical_line(a, b)
#   * else if a.y == b.y
#     * draw_horizontal_line(a, b)

# This is useless for the real input size but we might harvest it for parts maybe
# find largest viable rectangle in completed tile map
class TileMap
  def initialize(map, combinations)
    # at the moment our class expects a string as the map input
    # this might change depending on how we build the map
    @map = map.split("\n").map(&:chars)
    @combinations = combinations
  end

  def largest_area
    rectangle_records = []
    @combinations.each do |pair1, pair2|
      next unless valid_rectangle?(pair1, pair2)

      rectangle_records << {
        area: area(pair1, pair2),
        pairs: [pair1, pair2]
      }
    end
    rectangle_records.max_by { |record| record[:area] }[:area]
  end

  private

  def all_red_and_green?(upper_left, x_length, y_offset)
    valid_chars = ['#', 'X']
    @map[upper_left.y + y_offset][upper_left.x, x_length].all? do |char|
      valid_chars.include?(char)
    end
  end

  def area(pair1, pair2)
    line_length(pair1.x, pair2.x) * line_length(pair1.y, pair2.y)
  end

  def line_length(first, second)
    ((second - first).abs + 1)
  end

  def min_pair(pair1, pair2)
    [pair1, pair2].min_by { |pair| [pair.x, pair.y] }
  end

  def valid_pair?(pair1, pair2)
    (pair1.x <= pair2.x && pair1.y <= pair2.y) ||
      (pair2.x <= pair1.x && pair2.y <= pair1.y)
  end

  def valid_rectangle?(pair1, pair2)
    return false unless valid_pair?(pair1, pair2)

    upper_left = min_pair(pair1, pair2)

    x_length = line_length(pair1.x, pair2.x)
    y_length = line_length(pair1.y, pair2.y)

    # make sure all squares are red and green
    y_length.times do |y_offset|
      return false unless all_red_and_green?(upper_left, x_length, y_offset)
    end
    true
  end
end

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

completed_test_map = <<~HEREDOC
  ..............
  .......#XXX#..
  .......XXXXX..
  ..#XXXX#XXXX..
  ..XXXXXXXXXX..
  ..#XXXXXX#XX..
  .........XXX..
  .........#X#..
  ..............
HEREDOC

t = Time.now
ordered_pairs = extract_pairs_from_file('input.txt')
# ordered_pairs = extract_pairs_from_text(test_input)
red_tile_combinations = ordered_pairs.combination(2).to_a
puts "Time: #{Time.now - t}"
