# frozen_string_literal: true

#
# P:
#
# We need to count every time the dial crosses zero. This can happen many times
# during a large rotation, say `R1000`.
#
# Etc:
#
# Obviously there is a brute force approach whereby
# the dial object enacts the rotation incrementally and simply counts the number of
# times it alights on or passes through zero. I would assume this is prohibitively
# expensive in Ruby.
#
# Another option might be to (integer) divide the number of clicks by 100.
#
# dial -> 50, R1000
# 1000 + 50 = 1050
# 1050 / 100 = 10
# 10 times is correct
#
# Testing the given examples in IRB, it seems to work on both Left and Right rotations.
# However, if the dial is at, say, 50, and we rotate left by 50, then
# 50 - 50 = 0
# 0 / 100 = 0
# But of course, the dial has reached 0 so the correct answer is 1.
#
# So the algorithm is something like,
# * rotate the dial to keep track of the dial's state
# * if the dial now points to 0 AND the dial's previous state + the rotation clicks == 0
#   * add 1 to the accumulator
#   * skip to the next rotation
# * otherwise, we add the dial's previous state to the rotation clicks and divide by 10
# * the abs value of the result gets added to the accumulator and we advance to the next iteration
#
# NO. Another problem. dial -> 0, L1
# Here, 0 - 1 = -1
# the dial has not crossed 0 during the rotation, nor does it end up on 0, and yet
# -1 / 100 = -1 (according to the integer division algorithm, which mathematically
# is the same as `((-1).fdiv(100)).floor`).
#
# Not sure how to guard against this.
#
# We could simply say that if the starting point of the rotation is 0 and the sum is
# between -1 and -99, then we advance to the next rotation without adjusting the
# accumulator. This is not that satisfying though.
# Aaaand it doesn't even work.
#
# The brute force solution did actually work instantly, so a more mathematically
# clever solution isn't really needed. I would like to know though...
#
# DS:
#
# A:

# The dial
class Dial
  attr_reader :number

  def initialize
    @number = 50
  end

  def turn!(direction, clicks)
    neg_adj = (direction == 'L' ? -1 : 1)
    acc = 0
    clicks.times do |_|
      @number = (@number + neg_adj) % 100
      acc += 1 if @number.zero?
    end
    acc
  end
end

# Parse rotations given in input file string
class Parser
  class << self
    def process(input)
      lines = input.split("\n")
      lines.each_with_object([]) do |line, result|
        rotation = {}
        rotation[:direction] = line[0].upcase
        rotation[:clicks] = line[1..].to_i
        result.push rotation
      end
    end
  end
end

# Orchestration class
class FindPassword
  class << self
    def in(file)
      # rubocop:disable Style/ExpandPathArguments
      root = File.expand_path('..', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
      input = File.read(File.join(root, file))
      rotations = Parser.process(input)
      dial = Dial.new

      result = rotations.reduce(0) do |acc, rotation|
        acc + dial.turn!(rotation[:direction], rotation[:clicks])
      end
      puts result
    end
  end
end

FindPassword.in 'input1.txt'

# answer: 6892
