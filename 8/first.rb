# frozen_string_literal: true

# P:
#   Work out the distance between the points in the list of points
#   and sort the pairs of points by their distances.
#   Now build an array of circuits, where the first is the pair of points
#   closest together.
#   iterate over the remaining pairs of points, advancing from closest to furthest.
#   for each pair,
#   if any of the circuits have pair.a but NOT pair.b in it
#     add pair.b to that circuit
#   else if any of the circuits have pair.b but NOT pair.a in it
#     add pair.a to the circuit.
#   else if none of the circuits have either
#     add the pair array as a new item in the circuits array of arrays
#   else (one of the circuits has both)
#     do nothing
# Then,
#   multiply together the sizes of the 3 largest circuits
# Etc:
#
# DS:
#
# A:

require 'set'

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

circuits = [distances.pop[:boxes]]
boxes.delete(circuits.first[0])
boxes.delete(circuits.first[1])

999.times do
  a, b = distances.pop[:boxes]
  if circuits.none? { |circuit| circuit.include?(a) || circuit.include?(b) }
    circuits << [a, b]
    boxes.delete(a)
    boxes.delete(b)

    next
  end
  # i think if one circuit contains `a` and one contains `b`, then you
  # have to merge those circuits
  circuit_with_a = circuits.find { |circuit| circuit.include?(a) }
  circuit_with_b = circuits.find { |circuit| circuit.include?(b) }
  next if circuit_with_a && circuit_with_a == circuit_with_b

  if circuit_with_a && circuit_with_b && circuit_with_a != circuit_with_b
    (circuit_with_a << circuit_with_b).flatten!.uniq!
    circuits.delete(circuit_with_b)
    next
  end

  circuits.each do |circuit|
    if circuit.include?(a) && !circuit.include?(b)
      circuit << b
      boxes.delete(b)
      break
    elsif circuit.include?(b) && !circuit.include?(a)
      circuit << a
      boxes.delete(a)
      break
    end
  end
end

answer = circuits.map(&:size).sort.reverse.take(3).reduce(:*)

puts "Answer: #{answer}"

puts "Time: #{Time.now - t}"

# Answer: 42315
