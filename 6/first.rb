# frozen_string_literal: true

# P:
#
# Etc:
#
# DS:
#
# A:
#

OPERATIONS = %w[+ *].freeze

test_input = <<~HEREDOC
  123 328  51 64
   45 64  387 23
    6 98  215 314
  *   +   *   +
HEREDOC

# rubocop:disable Style/ExpandPathArguments
input = File.read(File.join(File.expand_path('..', __FILE__), 'input.txt'))
# rubocop:enable Style/ExpandPathArguments

problems = input.split("\n").map(&:split)

problem_operations = problems.pop

number_of_columns = problems.size
number_of_rows = problems.first.size

problem_datasets = Array.new(number_of_rows) { Array.new(number_of_columns) }

problems.each_with_index do |row, row_index|
  row.each_with_index do |datum, column_index|
    problem_datasets[column_index][row_index] = datum
  end
end

split_datasets = problem_datasets.partition.with_index do |_, index|
  problem_operations[index] == '+'
end

answer = 0
split_datasets.first.each do |dataset|
  answer += dataset.reduce(0) { |acc, number| acc + number.to_i }
end

split_datasets.last.each do |dataset|
  answer += dataset.reduce(1) { |acc, number| acc * number.to_i }
end

puts answer
