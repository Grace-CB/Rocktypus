#!/usr/bin/env ruby

require './Tenticle'

# Start up (add check-for-command-line-flags eventually but not right now)

a = Tenticle::Cups.new # Create one tenticle for the init stuff

a.init(ARGV) # Should catch the status of initialization for error decomposition

#b = Tenticle::Cups.new # This tenticle is going to throw our errors and suchness

#b.err("This is diagnostic level, for FYI messages.", 2)
#b.err("Warning level, for things that aren't fatal.", 1)
#b.err("Exception level! Perfidy!", 0)
#b.err("This doesn't happen.", 5)

#puts "We didn't quit, or else this wouldn't be here."

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

