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
# DS:
#
# A:

OrderedPair = Struct.new('OrderedPair', :x, :y)
AreaData = Struct.new('AreaData', :area, :pair)

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

area_infos = pairs.combination(2).map do |pair1, pair2|
  AreaData.new(rectangle_area(pair1, pair2), [pair1, pair2])
end

largest_area_info = area_infos.max_by { |area| area[:area] }

puts "Answer: #{largest_area_info.area}"
puts "Time: #{Time.now - t}"
