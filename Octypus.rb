#!/usr/bin/env ruby

require './Tenticle'

# Start up (add check-for-command-line-flags eventually but not right now)

a = Tenticle::Cups.new # Create one tenticle for the init stuff

a.init(ARGV) # Should catch the status of initialization for error decomposition

b = Tenticle::Cups.new # This tenticle is going to throw our errors and suchness

b.err("You wanted to know, baby.", 2)
b.err("Just a jerk.", 1)
b.err("Calumny and perfidy!", 0)

b.err("This doesn't happen.", 2)

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

