# frozen_string_literal: true

# P:
# Even though I got the right answer for the first part, the model
# doesn't seem to work for this part.
# Thoroughly confused by what the first part specification so this is
# not surprising.
#
# Essentially there are these boxes in various places defined by 3d coordinates.
# We connect them in ascending order of the distance between from one box to another.
#
# We get a list of the distances between boxes in asecending order along with the
# pair of boxes the distance refers to.
#
# The first part wanted us to connect the boxes according to the first ten shortest
# distances.
#
# So I worked through the list from shortest distance onwards.
# I had a list of circuits, with each circuit being a list of connected boxes.
# This list of circuits starts with the circuit formed by the two boxes whose
# distance is shortest.
# Beginning with the next shortest distance
#   If none of the existing circuits contain either of the boxes referred to by the
#   current distance, we create a new circuit list containing these two boxes
#
# Ok, I realize now that 'circuits' in the problem text includes boxes
# that have not been connected at all. Since all the connected boxes
# have been merged into one single circuit by the time the last two boxes
# are added into the circuits array, the point where the boxes array is empty
# is the point where all the boxes are connected in a single circuit.
#
# Perhaps it would make more sense to write
# `last_two = [a, b] if boxes.empty? && circuits.size == 1`
# but the second condition was unnecessary in both test input and real input.
#
# Easily the most opaque problem specification I've encountered in AoC.
#
# Etc:
#
# DS:
#
# A:

def reverse_sorted_distances_between_boxes(boxes)
  distances = []
  boxes.combination(2) do |a, b|
    distances << { distance: distance_between_boxes(a, b), boxes: [a, b] }
  end
  distances.sort { |a, b| b[:distance] <=> a[:distance] }
end

def distance_between_boxes(box1, box2)
  box1_vec = box1.split(',').map(&:to_i)
  box2_vec = box2.split(',').map(&:to_i)

  Math.sqrt(
    ((box1_vec[0] - box2_vec[0])**2) +
    ((box1_vec[1] - box2_vec[1])**2) +
    ((box1_vec[2] - box2_vec[2])**2)
  )
end

def junction_box_strings_from_file(filename)
  # rubocop:disable Style/ExpandPathArguments
  path = File.expand_path('..', __FILE__)
  # rubocop:enable Style/ExpandPathArguments
  file_path = File.join(path, filename)
  junction_box_strings_from_text(File.read(file_path))
end

def junction_box_strings_from_text(text)
  text.split("\n").map(&:chomp)
end

test_input = <<~HEREDOC
  162,817,812
  57,618,57
  906,360,560
  592,479,940
  352,342,300
  466,668,158
  542,29,236
  431,825,988
  739,650,466
  52,470,668
  216,146,977
  819,987,18
  117,168,530
  805,96,715
  346,949,466
  970,615,88
  941,993,340
  862,61,35
  984,92,344
  425,690,689
HEREDOC

t = Time.now

input_file = 'input.txt'
boxes = junction_box_strings_from_file(input_file)

distances = reverse_sorted_distances_between_boxes(boxes)
circuits = boxes.map { |box| [box] }

until distances.empty?
  a, b = distances.pop[:boxes]

  circuit_with_a = circuits.find { |circuit| circuit.include?(a) }
  circuit_with_b = circuits.find { |circuit| circuit.include?(b) }
  next if !circuit_with_a.nil? && (circuit_with_a == circuit_with_b)

  next unless !circuit_with_a.nil? && !circuit_with_b.nil? &&
              (circuit_with_a != circuit_with_b)

  circuit_with_a.concat(circuit_with_b)
  circuits.delete(circuit_with_b)
  if circuits.size == 1
    last_two = [a, b]
    break
  end
end

last_two_x = last_two.map { |num_string| num_string.split(',').first.to_i }
answer = last_two_x.reduce(:*)

puts "Answer: #{answer}"
puts "Time: #{Time.now - t}"

# Answer: 8079278220
