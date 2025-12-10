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

top_left = pairs.min_by { |pair| pair.x + pair.y }
bottom_right = pairs.max_by { |pair| pair.x + pair.y }
top_right = pairs.max_by { |pair| pair.x - pair.y }
bottom_left = pairs.max_by { |pair| pair.y - pair.x }

p [[top_left, bottom_right], [bottom_left, top_right]]

areas = []
areas << rectangle_area(top_left, bottom_right)
areas << rectangle_area(bottom_left, top_right)

answer = areas.max

puts "Answer: #{answer}"
puts "Time: #{Time.now - t}"
