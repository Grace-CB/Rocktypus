#!/usr/bin/env ruby

require './Tenticle'

# Start up (add check-for-command-line-flags eventually but not right now)

a = Tenticle::Cups.new(ARGV)  # Create a tenticle and init default options,
                              # check for incoming command line options,
                              # etc. etc.

puts a.list

a.err("This is diagnostic level, for FYI messages.", 2)
a.err("Warning level, for things that aren't fatal.", 1)
a.err("Exception level! Perfidy!", 0)
a.err("This doesn't happen.", 5)


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

