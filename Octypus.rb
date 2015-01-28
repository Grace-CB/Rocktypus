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

# Refactor this later, and we can make it flexible enough to call single iteration
# versions of the function for single-element lists but looped versions for multi-element
# lists. It'll reduce overhead, too, maybe. Benchmark trials should give proof.

# TODO: Refactor our test execution into a method so that we can handle multiples of any aspect of the execution
# TODO: Make sure that method still keeps track of the data so that it knows when it's got a 'complete' gless command
# TODO: Fix the diagnostics to accurately reflect what's being detected in the Cuisinart, because we don't have a 'lie' errorlevel
# TODO: Massage reporting for readability

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
      t = Time.new
      time = [ [ t.day, t.mon, t.year ].join("-"), [ t.hour, t.min, t.sec ].join("-") ].join(" ")
      result = File.read( './raw/Output 12-3-14-19-1-2015-1-19-false-PST' )
#      result = %x( #{execstring} 2>&1 )
      a.err( "Finished execution, outputting result.", 2 )
#      result = result.gsub(/\e\[\d{1,2}m/, '')
#      File.write( "./raw/Output #{ tstamp.to_a.join("-")}", result)

    }

  }

# Next up, we filter out errything that passes and report-format everything that doesn't. We've still got it in result.

class Cuisinart

  include CommandLineReporter

  @a = ''

  def initialize(a)
    self.formatter = 'progress'
    @a = a
  end

  def run(result)
    processed = []
#    report.do
    length = result.length
    index = 0

    previous = ''
    error = FALSE

    result.each_line { |line|

      line = line.gsub(/^.{,35}/, '')					# Strip timestamp and epoch and blank space after
      index = index + 1

      if (index <= 9)
	next
      elsif (line.match(/^\W{4}\w/))					# Ignore most lines with 4 whitespaces in front.
        @a.err("Skipping #{ line }.", 2)
      elsif (error)							# If there's an error, catch the lines in the diff.
        processed.push(line)
        @a.err("Caught because error flagging.", 2)
      elsif (line.match(/^\W{4}\w/) and previous.match(/^\W{6}\w/))	# If we're at the start of an error, start recording and catch the line before.
        error = FALSE
        processed.push(previous)
        processed.push(line)
        @a.err("Caught an ending line and previous.", 2)
      elsif (line.match(/^\W{6}\w/) and previous.match(/^\W{4}\w/))	# If we're at the end of an error, stop recording.
        error = TRUE
        processed.push( " >>>> FAILED AT <<<< " )
        processed.push(previous)
        processed.push(line)
        @a.err("Caught a beginning line.", 2)
      elsif (line.match(/^\W{6}\w/))					# Catch any lines that happen to be indented enough to be error or diff.
        processed.push(line)
        @a.err("Catching an error because of indentation.", 2)
      elsif (line.match(/^\w/))						# Catch any lines that haven't got any indentation.
        processed.push(line)
        @a.err("Catching a line because of lack of indentation.", 2)
      end

      previous = line

    }

    puts "Processed is: "
    puts processed

    t = Time.new
    time = [ [ t.day, t.mon, t.year ].join("-"), [ t.hour, t.min, t.sec ].join("-") ].join(" ")

    puts "Processed at: #{ time }"

    report = processed.join("")

    File.write( "./reports/Octypus Report - #{ time }", report )

  end

end

class Hopper

  def initialize (options)          # A six-item array with an integer (iteration count) and then five arrays
                                    # -- servers, tests, browsers, platforms, versions
    @o = options

    @count        = @o[:count]
    @servers      = @o[:servers]
    @tests        = @o[:tests]
    @browsers     = @o[:browsers]
    @platforms    = @o[:platforms]
    @versions     = @o[:versions]
    @stats        = []

    # create a timestamped directory for this batch of tests

  end

  def empty

    @servers.each { |server|

      @server = server

      @tests.each { |test|

        @test = test

        @browsers.each { |browser|

          @browser = browser

          @platforms.each { |platform|

            @platform = platform

            @versions.each { |version|

              tstamp = Time.new               # New timestamp for each run
              uid = %x( ruby uid.rb )             # New UID for each run

              # Pack up the vars into the executable string
              execstring = '/usr/bin/gless #{ test } #{ server } GE_BROWSER="#{ browser }" GE_PLATFORM="#{ platform }" GE_BROWSER_VERSION="#{ version }"'
              result = %x( #{execstring} 2>&1 )

              # File.write( "./raw/Output UID-#{uid}--TIME-#{ tstamp.to_a.join("-") }", result) # Drop the output into a file
              result = result.gsub(/\e\[\d{1,2}m/, '')            # Strip formatting


              filter = Cuisinart.new(a)
              filter.run(result)

                  # File.write( "./report/Output UID-#{uid}--TIME-#{ tstamp.to_a.join("-") }", result)  # Drop the report into a file

                  # store the stat info

          }

        }

      }

    }

  }

  end

end

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
