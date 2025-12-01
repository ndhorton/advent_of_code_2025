# frozen_string_literal: true

#
# P:
#
# We need to find the password from a series of rotations of a circular dial.
# The password is the number of times the dial is left pointing at 0 after
# and rotation in a given sequence of rotations of the dial. The dial loops around
# so that rotating the dial by 1 to the right from 99 gives you 0, etc.
# The dial starts at 50.
#
#
# Etc:
#
# DS:
#
# class Dial
# @number --- starts at 50, min 0 and max 99
# #number --- get @number
# #rotate(direction, clicks) --- rotates dial in the given direction by clicks
#
# class Parser
#
# A:
#

# The dial
class Dial
  attr_reader :number

  def initialize
    @number = 50
  end

  def turn!(direction, clicks)
    clicks = -clicks if direction == 'L'
    @number = (@number + clicks) % 100
  end
end

# Parse rotations given in input file string
class Parser
  VALID_DIRECTIONS = %w[L R].freeze
  class << self
    def process(input)
      result = []
      lines = input.split("\n")
      lines.each do |line|
        next unless VALID_DIRECTIONS.include?(line[0].upcase)

        rotation = {}
        rotation[:direction] = line[0].upcase
        rotation[:clicks] = line[1..].to_i

        result.push rotation
      end

      result
    end
  end
end

# Orchestration class
class FindPassword
  class << self
    def from(file)
      # rubocop:disable Style/ExpandPathArguments
      root = File.expand_path('..', __FILE__)
      # rubocop:enable Style/ExpandPathArguments
      input = File.read(File.join(root, file))
      rotations = Parser.process(input)
      dial = Dial.new
      acc = 0
      rotations.each do |rotation|
        dial.turn!(rotation[:direction], rotation[:clicks])
        acc += 1 if dial.number.zero?
      end
      puts acc
    end
  end
end

FindPassword.from 'input1.txt'
