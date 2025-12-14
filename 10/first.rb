# frozen_string_literal: true

# P:
# What is the fewest button presses required to correctly configure the
# lights on all the machines?
#
# Etc:
# Given an indicattor light diagram, the best scenario is that there is
# a single button that toggles all the correct lights. Then the fewest presses
# is 1.
# From there on it gets much more complicated.
# In order to get any given light into the right state, we need an odd number
# of occurrences of the index of that light in the button presses.
#
# So the first pass might search for a button that contains all the right
# indices, then search for a combination of two buttons that would give
# an odd number of toggles to the right lights. Then search for a combination
# of three buttons that would give an odd number of indices for the right lights.
# And so on until we have looked at the case where we press all buttons once.
#
# But I don't know if this is even a good idea for a first pass, since
# obviously pushing a button twice and another button once is better than
# pushing four different buttons.
#
# Where do you start and where do you stop?
# Do you start by looking for the button with the largest number of correct light
# indexes?
#
# Do we start by generating the ideal button and then comparing the actual
# buttons?
# Given [.##.]
# The ideal button is (1, 2)
# The actual buttons are (3) (1,3) (2) (2, 3) (0, 1)
# Candidates that toggle the correct lights are
#   (1, 3) (2) (2, 3) (0, 1)
#
#
# DS:
#
# A:
