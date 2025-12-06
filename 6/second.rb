# frozen_string_literal: true

# P:
#
# Etc:
#
# So we essentially need to do a matrix transposition of the entire numbers
# field after removing the ops.
#
# We need to reverse the ops because the numbers are now in left-to-right order.
#
# DS:
#
# A:
#  Split into problem_lines, keeping the spaces at the end of lines
#  remove last row and reverse it, as problem_ops
#

t = Time.now
# rubocop:disable Style/ExpandPathArguments
input = File.read(File.join(File.expand_path('..', __FILE__), 'input.txt'))
# rubocop:enable Style/ExpandPathArguments
problem_lines = input.split("\n")
problem_ops = problem_lines.pop.split.reverse

last_column_index = problem_lines.first.size - 1

solution_matrix = []
new_row = []
last_column_index.downto(0) do |col_index|
  new_number = []
  problem_lines.each_index do |row_index|
    new_number << problem_lines[row_index][col_index]
  end
  if new_number.all?(' ')
    solution_matrix << new_row
    new_row = []
  else
    new_row << new_number.join.to_i
  end
end
solution_matrix << new_row

acc = 0

problem_ops.each_with_index do |op, index|
  acc += solution_matrix[index].reduce(op.to_sym)
end

puts "Answer: #{acc}"
puts "Time: #{Time.now - t}"

# Answer: 12841228084455
