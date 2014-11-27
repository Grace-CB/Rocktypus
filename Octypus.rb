#!/usr/bin/env ruby

$LOAD_PATH << '.'

require_relative 'Tenticle'

# Start up (add check-for-command-line-flags eventually but not right now)

A = Tenticle::Arm.initialize(ARGV) # Should catch the status of initialization for error decomposition

B = Tenticle::Arm.new() # This is going to throw our errors and suchness

B.Arm.ize("Cupsize", "babycakes")

B.Arm.err("You wanted to know, baby.", 2)
B.Arm.err("Just a jerk.", 1)
B.Arm.err("Calumny and perfidy!", 0)

B.Arm.err("This doesn't happen.", 2)



# This is where the Octypus primary logic goes
# we'll write a helper module from the half-built version after we set up SVN for eclipse


# Load a config file (ideally in YAML so I don't have to reconceptualize that)
#
# Execute the given test the number of times indicated on the servers given
#
# Take the raw output of the tests and filter out non-error lines/info
#
# Produce reformatted reports
#
# Shut down
#
#