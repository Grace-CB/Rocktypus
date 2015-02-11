#!/usr/bin/env ruby

require './Tenticle'
require 'yaml'
require 'command_line_reporter'

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

#browser = a.options[:browser]
#platform = a.options[:platform]
#version = a.options[:browserversion]

#fbrowser = "GE_BROWSER=\"#{browser}\""
#fplatform = "GE_PLATFORM=\"#{platform}\""
#fversion = "GE_BROWSER_VERSION=\"#{version}\""

#latterhalf = [fbrowser, fplatform, fversion].join( " " )

# Refactor this later, and we can make it flexible enough to call single iteration
# versions of the function for single-element lists but looped versions for multi-element
# lists. It'll reduce overhead, too, maybe. Benchmark trials should give proof.

# TODO: Refactor our test execution into a method so that we can handle multiples of any aspect of the execution
# TODO: Make sure that method still keeps track of the data so that it knows when it's got a 'complete' gless command
# TODO: Fix the diagnostics to accurately reflect what's being detected in the Cuisinart, because we don't have a 'lie' errorlevel
# TODO: Massage reporting for readability

result = []

# This will be replaced by the Hopper class, which handles multiple options for each aspect of a gless run
# EXCEPT browsers. At this point, I'd need to set up too much data validation and it would make runs wonky.
#
# TODO: Fix the browser-singularness.

#a.options[:tests].each {
#    |test|
#
#    a.info( "For each test, we are iterating.")
#
#    a.options[:servers].each {
#      |server|
#
#      a.info( "For each server, we are iterating.")
#
#      a.info( "Here's where we start the run of test #{ test } on server #{ server }.")
#      formerhalf = "/usr/local/bin/gless #{test} #{server} "
#      a.info( "We'll use the execution string #{ formerhalf + latterhalf }")
#      execstring = formerhalf + latterhalf
#      a.info( "This is our string post-concatenation: #{ execstring }")
#      t = Time.new
#      time = [ [ t.day, t.mon, t.year ].join("-"), [ t.hour, t.min, t.sec ].join("-") ].join(" ")
#      result = File.read( './raw/Output 12-3-14-19-1-2015-1-19-false-PST' )
#      result = %x( #{execstring} 2>&1 )
#      a.info( "Finished execution, outputting result.")
#      result = result.gsub(/\e\[\d{1,2}m/, '')
#      File.write( "./raw/Output #{ tstamp.to_a.join("-")}", result)
#
#    }
#
#  }

# Next up, we pass it all to the hopper and then empty it out.
# The hopper calls for the Cuisinart to filter out errything that passes and report-format everything that doesn't. We
# still put the raw stuff in the raw file, and filtering gives us the report version.

hopper = Tenticle::Hopper.new( 

  :count => a.times,
  :servers => a.servers,
  :tests => a.tests,
  :browsers => a.browsers,
  :platforms => a.platforms,
  :versions => a.versions

)

hopper.empty

# The 'many if many one if one' thing is probably going to be a PITA to implement for a very small run cost.
# Leave it off for later, if there are issues with resource hogging on highly asymmetrical runs (i.e., one
# value for one or two things, several for all the rest)

# Take the raw output of the tests and filter out non-error lines/info
#
# Produce reformatted reports
#
# Shut down
#



#TODO: Concurrency? Can we create a 'matrix of events' style yaml structure in order to assign sequences and simultaneous tests?
#TODO: Fuzzy filefinding? If we get a typo'd name for a test, can we look for the closest thing? Is that even a good idea?
#INFO: I don't want to get into full scripting on this.
