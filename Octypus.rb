#!/usr/bin/env ruby

require './Tenticle'
require 'yaml'

# Start up (add check-for-command-line-flags eventually but not right now)

a = Tenticle::Cups.new(ARGV)  # Create a tenticle and init default options,
                              # check for incoming command line options,
                              # etc. etc.



#File.open('database.yml', 'w') do |file|
#  file.write(Psych.dump([b, c, d]))
#end

a.err("This is diagnostic level, for FYI messages.", 2)
a.err("Warning level, for things that aren't fatal.", 1)
a.err("Exception level! Perfidy!", 0)
#a.err("This doesn't happen.", 5)


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

#TODO: Concurrency? Can we create a 'matrix of events' style yaml structure in order to assign sequences and simultaneous tests?
#TODO: Fuzzy filefinding? If we get a typo'd name for a test, can we look for the closest thing? Is that even a good idea?
#INFO: I don't want to get into full scripting on this.
