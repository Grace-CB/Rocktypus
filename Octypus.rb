#!/usr/bin/env ruby

require './Tenticle'
require 'yaml'

# Start up (add check-for-command-line-flags eventually but not right now)

a = Tenticle::Cups.new(ARGV)  # Create a tenticle and init default options,
                              # check for incoming command line options,
                              # etc. etc.


# This was our stringything in Perl Octypus:
# q(/usr/local/bin/gless) . " " . qq($test $server GE_BROWSER='$brow' GE_PLATFORM='$plat' GE_BROWSER_VERSION='$ver');

#File.open('database.yml', 'w') do |file|
#  file.write(Psych.dump([b, c, d]))
#end

#a.err("This is diagnostic level, for FYI messages.", 2)
#a.err("Warning level, for things that aren't fatal.", 1)
#a.err("Exception level! Perfidy!", 0)
#a.err("This doesn't happen.", 5)

browser = a.options[:browser]
platform = a.options[:platform]
version = a.options[:browserversion]
latterhalf = "GE_BROWSER=#{browser} GE_PLATFORM=#{platform} GE_BROWSER_VERSION=#{version}"

# TODO: Refactor this later, and we can make it flexible enough to call single iteration
# versions of the function for single-element lists but looped versions for multi-element
# lists. It'll reduce overhead, maybe. Benchmark?

a.options[:tests].each {

    |test|
    a.options[:servers].each {

      |server|

      puts "Here's where we start the run of test #{ test } on server #{ server }."
      formerhalf = '/usr/local/bin/gless ' + test + " " + server + " "
      execstring = formerhalf + latterhalf
      puts execstring
      %x( #{execstring} )




    }

  }


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
