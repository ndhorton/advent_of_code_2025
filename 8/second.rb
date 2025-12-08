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
# Etc:
#
# DS:
#
# A:

def distance_between(a, b)
  a_vec = a.split(',').map(&:to_i)
  b_vec = b.split(',').map(&:to_i)
  Math.sqrt(
    ((a_vec[0] - b_vec[0])**2) +
    ((a_vec[1] - b_vec[1])**2) +
    ((a_vec[2] - b_vec[2])**2)
  )
end

def vector_strings_from_text(text)
  text.split("\n").map do |line|
    line.chomp
  end
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

# rubocop:disable Style/ExpandPathArguments
path = File.expand_path('..', __FILE__)
# rubocop:enable Style/ExpandPathArguments
file_path = File.join(path, 'input.txt')
input = File.read(file_path)

boxes = vector_strings_from_text(input)
distances = []
boxes.combination(2) do |a, b|
  distances << { distance: distance_between(a, b), boxes: [a, b] }
end
distances.sort! { |a, b| b[:distance] <=> a[:distance] }

# File.open('debug_output.txt', 'w') do |file|
#   distances.each { |distance| file.puts distance[:boxes].inspect }
# end

circuits = [distances.pop[:boxes]]
boxes.delete(circuits.first[0])
boxes.delete(circuits.first[1])

last_two = nil

until boxes.empty?
  a, b = distances.pop[:boxes]

  if circuits.none? { |circuit| circuit.include?(a) || circuit.include?(b) }
    circuits << [a, b]
    boxes.delete(a)
    boxes.delete(b)
    last_two = [a, b] if boxes.empty?
    next
  end
  # if one circuit contains `a` and one contains `b`, then you
  # have to merge those circuits
  circuit_with_a = circuits.find { |circuit| circuit.include?(a) }
  circuit_with_b = circuits.find { |circuit| circuit.include?(b) }
  next if !circuit_with_a.nil? && (circuit_with_a == circuit_with_b)

  if circuit_with_a && circuit_with_b && (circuit_with_a != circuit_with_b)
    circuit_with_a.concat(circuit_with_b)
    circuits.delete(circuit_with_b)

    next
  end

  circuits.each do |circuit|
    if circuit.include?(a) && !circuit.include?(b)
      circuit << b
      boxes.delete(b)
      last_two = [a, b] if boxes.empty?
      break
    elsif circuit.include?(b) && !circuit.include?(a)
      circuit << a
      boxes.delete(a)
      last_two = [a, b] if boxes.empty?
      break
    end
  end
end
p last_two
last_two.map! { |num_string| num_string.split(',').first.to_i }
answer = last_two.reduce(:*)
puts "Answer: #{answer}"
puts "Time: #{Time.now - t}"

# Answer: 8079278220
