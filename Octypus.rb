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

browser = a.options[:browser]
platform = a.options[:platform]
version = a.options[:browserversion]

fbrowser = "GE_BROWSER=\"#{browser}\""
fplatform = "GE_PLATFORM=\"#{platform}\""
fversion = "GE_BROWSER_VERSION=\"#{version}\""

latterhalf = [fbrowser, fplatform, fversion].join( " " )


# TODO: Refactor this later, and we can make it flexible enough to call single iteration
# versions of the function for single-element lists but looped versions for multi-element
# lists. It'll reduce overhead, too, maybe. Benchmark trials should give proof.

result = []

a.options[:tests].each {
    |test|

    a.err( "For each test, we are iterating.", 2 )

    a.options[:servers].each {
      |server|

      a.err( "For each server, we are iterating.", 2 )

      a.err( "Here's where we start the run of test #{ test } on server #{ server }.", 2)
      formerhalf = "/usr/local/bin/gless #{test} #{server} "
      a.err( "We'll use the execution string #{ formerhalf + latterhalf }", 2)
      execstring = formerhalf + latterhalf
      a.err( "This is our string post-concatenation: #{ execstring }", 2)
      tstamp = Time.new
#      result = "result"
      result = %x( #{execstring} 2>&1 )
      a.err( "Finished execution, outputting result.", 2 )
      result = result.gsub(/\e\[\d{1,2}m/, '')
      File.write( "./raw/Output #{ tstamp.to_a.join("-")}", result)
      

    }

  }

# Next up, we filter out errything that passes and report-format everything that doesn't. We've still got it in result.

processed = []

class Cuisinart {

  include CommandLineReporter

  def initialize
    self.formatter = 'progress'
  end

  def run
    report.do
    length = result.length 
    count = 0
    
    result.each_with_index
      |line, index|

      if (index <= 7) 
	next
      else
        processed = processed + line 
      end

    end

  end

}

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
