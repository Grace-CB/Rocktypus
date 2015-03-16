module Tenticle

require "highline/import"
require "trollop"
require "logger"
require "command_line_reporter"

  #  trollop options settable at command line include:
  #  (S)ervers to test on
  #  (T)ests to run
  #  (I)terations of each test
  #  (E)rrorlevel
  #  (B)rowser flavor
  # b(R)owser version

  module Help

    class << self

      attr_accessor :stats, :log, :debug

    end

    self.stats = {}

    self.log = Logger.new(STDOUT)                                             # New logger at the module level
    log.formatter = proc{ |severity, datetime, progname, msg| puts msg }			# Fish out the error message only

    def self.stamp

      t = Time.new
      stamp = [
        [ Help.rj(t.day), Help.rj(t.mon), t.year ].join("-"),
        [ Help.rj(t.hour), Help.rj(t.min), Help.rj(t.sec) ].join("=")
      ].join(" ")
      return stamp

    end

    self.debug = "0"                                                                            # By default, not debugging

    def self.rj(digit)
      return digit.to_s.rjust(2, "0")
    end

    def self.err(message)

      log.error(message)

    end

    def self.warn(message)

      log.warn(message)

    end

    def self.info(message)

      log.info(message)

    end

    def self.fatal(message)

      log.fatal( "FATAL: " + message + " EXITING.")

    end

  end

  class Cups

    include Help

    attr_accessor :file, :times, :servers, :tests, :platforms, :browsers, :versions

    # Cups provides Tenticle with grip. In this case, that means setting configuration
    # state, handling command line alterations for it, and wrapping logger methods.

    @errorlevel = ''
    @tests = []
    @servers = []
    @options = []
    @file = ''
    @times = ''
    @browsers = []

    def initialize (args)

      # These define the basic configuration. They're altered by command line options.

      @options = Trollop::options do
        opt :debug, "Debug", :type => :integer, :default => '0'
        opt :file, "Filename", :type => :string, :default => 'cfg.yml'      			         # Default config is 'cfg.yml'
        opt :iterations, "Iterations", :type => :integer, :default => 3     			         # Default number of iterations is 3
        opt :servers, "Servers", :type => :strings, :default => ['qa-eris', 'qa-charon'] 	 	 # Defaults to qa-eris
        opt :tests, "Tests", :type => :strings, :default => ['very_tiny_perf_test']		         # Defaults to u937
        opt :errorlevel, "Error level", :type => :integer, :default => 0    			         # Defaults to 0 (fatals only)
        opt :platform, "OS", :type => :strings, :default => ['Windows 8']      			         # Defaults to Win8
        opt :browsers, "Browsers", :type => :strings, :default => ['firefox']    		         # Defaults to firefox
        opt :version, "Browser versions", :short => "-r",             			                 # Defaults to 33
          :type => :strings, :default => ['33']
      end

      @file = @options[:file]
      @times = @options[:iterations]
      @servers = @options[:servers]
      @tests = @options[:tests]
      @errorlevel = @options[:errorlevel]
      @platforms = @options[:platform]
      @browsers = @options[:browsers]
      @versions = @options[:version]
      Help.debug = @options[:debug]


      if (@errorlevel.to_s == '2')
         Help.log.level = Logger::WARN
      elsif (@errorlevel.to_s == '1')
         Help.log.level = Logger::ERROR
      elsif (@errorlevel.to_s == '0')
         Help.log.level = Logger::FATAL
      elsif (@errorlevel == NIL)
         Help.log.level = Logger::FATAL
      else
         Help.log.level = Logger::FATAL
         Help.log.fatal("Unknown error level setting attempted. Exiting.")
      end

      Help.log.info("@errorlevel was set to #{ @errorlevel }")
      Help.log.info("logger level was set to #{ Help.log.level }")

      # The hierarchy here is going to be default file, then specified file,
      # then command line options if specified. That way, we can run Octy with just
      # the default options we want.
      # TODO: add this information to the helpfile that trollop does.
      #
      # MAYBE: Consider highline for a later 'interactive specification' option, though?

    end

  end

  class Cuisinart

    include Help

    include CommandLineReporter

    @lines = ''

    attr_accessor :test_state

    @test_state = ""

      def initialize()

        self.formatter = 'progress'

      end

      def run(result)
        processed = []
    #    report.do
        length = result.length
        index = 0

        previous = ''
        error = false

        @test_state = "success"

        result.each_line { |line|

        line = line.gsub(/^.{,35}/, '')         # Strip timestamp and epoch and blank space after
        index = index + 1

        if (index <= 9)				# Ignore the first nine lines.

          next

        elsif (line.match(/^\W{4}\w/))          # Ignore most lines with 4 whitespaces in front.

          Help.log.info("Skipping #{ line }.")

        elsif (line.match(/^W, /))

          # (do stuff because it's a warning)
          line = line.gsub(/^[^\:]:\W{1}/, '')
          Help.log.info("Caught and stripped bare a warning line.")

        elsif (error)             		# If there's an error, catch the lines in the diff.

          processed.push(line)
          Help.log.info("Caught because error flagging.")

        elsif (
         line.match(/^\W{4}\w/) and
         previous.match(/^\W{6}\w/) )  		# If we're at the start of an error, start recording and catch the line before.

          error = false
          processed.push(previous)
          processed.push(line)
          Help.log.info("Caught an ending line and previous.")

        elsif (

         line.match(/^\W{6}\w/) and
         previous.match(/^\W{4}\w/) ) 		# If we're at the end of an error, stop recording.

          error = true
          @test_state = "failure"
          processed.push( " >>>> FAILED AT <<<< " )
          processed.push(previous)
          processed.push(line)
          Help.log.info("Caught a beginning line.")

        elsif (line.match(/^\W{6}\w/))          # Catch any lines that happen to be indented enough to be error or diff.

          processed.push(line)
          Help.log.info("Catching an error because of indentation.")

        elsif (line.match(/^\w/))           	# Catch any lines that haven't got any indentation.

          processed.push(line)
          Help.log.info("Catching a line because of lack of indentation.")

        end

        previous = line				# Next line. Store the last one.

      }


      puts "Processed is: "
      puts processed

      # t = Time.new
      # time = [ [ Help.rj(t.day), Help.rj(t.mon), t.year ].join("-"), [ Help.rj(t.hour), Help.rj(t.min), Help.rj(t.sec) ].join("=") ].join(" ")
      # replaced by Help.stamp

      puts "Processed at: #{ Help.stamp }"

      report = processed.join("")

      report

    end

  end

  class Hopper

    include Help

    attr_accessor :count, :servers, :tests, :browsers, :platforms, :versions

    def initialize (options)          # A six-item hash with an integer (iteration count) and then five arrays
                                      # -- servers, tests, browsers, platforms, versions. TODO Refactor later!
      @o = options

      @count        = @o[:count]
      @servers      = @o[:servers]
      @tests        = @o[:tests]
      @browsers     = @o[:browsers]
      @platforms    = @o[:platforms]
      @versions     = @o[:versions]


      # create a timestamped directory for this batch of tests

      if (Help.debug == 1)

        # MINI ROADMAP

        # 1. Finish result caching.
        # 2. Finish report generation.
        # 3. Finish stats generation.
        # 4. First release! Request for feedback.
        # 5. TBD (or "The Future")        

        # This is where we'll batch the files from a specific test run
        # so that we can stop running tests every time we need to 
        # test the function of this testing harness test test test. Test!

        # Okay, seriously: We're going to batch a specific test run's
        # result files in order to avoid running Selenium tests (which
        # cost money and therefore need to be avoided when possible).

        # We also have to swap in that specific test's option info
        # so that the number of tests being run and the stats info will
        # match up.

        # once this is done, we can move back to shaping report and stat
        # functionality, hopefully with real-time groovy outputs showing
        # fails and successes so far.

        # From THERE, we move to some intensive testing of basic u937
        # to determine the most common sort of errors and make it so the
        # report results can actually save human processing overhead.

        # This is where we shoehorn in caching of a sort.
        # In this case, it'll be three steps.

        # TODO One -- adding a debug option to the command line.

        # TODO Two -- in here, when we're in debug, we wipe out all the info
        # coming in and replace it with standardized info from the last
        # test batch.

        # TODO Three -- add a conditional around the actual system call so
        # we can skip it when we're running cached and instead pull in
        # one of the batched test results.

        # Everything else should work as is.

      end

    end

    def empty

      # Empties out the Hopper after it's loaded with gless run infos.

      @uid = %x( ruby uid.rb )
      @uid = @uid.chomp

      @servers.each { |server|

        @server = server

        @tests.each { |test|

          @test = test

          @browsers.each { |browser|

            @browser = browser

            @platforms.each { |platform|

              @platform = platform

              @versions.each { |version|

		runs = 0

                while runs < @count

                # t = Time.new                                          	               # New timestamp for each run
                # time = [ [ Help.rj(t.day), Help.rj(t.mon), t.year ].join("-"),			   # Format for the report
                #        [ Help.rj(t.hour), Help.rj(t.min), Help.rj(t.sec) ].join("=") ].join(" ")
                # replaced by Help.stamp


                # Pack up the vars into the executable string
                execstring = '/usr/local/bin/gless ' +
                             test + " " + server + " GE_BROWSER=" +
                             browser + ' GE_PLATFORM="' + platform + '"' + " GE_BROWSER_VERSION=" + version
                puts execstring

                if (debug == 0)

                  result = %x( #{ execstring } 2>&1 )

                elsif (debug == 1)

                  # pick the file out of the list
                  # set results to the file's contents

                end

                Help.log.info( "Finished the executions." )

                File.write( "./raw/Output ##{@uid}-#{ Help.stamp }", result) 		             # Drop the raw output into a file
                result = result.gsub(/\e\[\d{1,2}m/, '')                       	       # Strip formatting

                filter = Cuisinart.new()
                filtered = filter.run(result)

                File.write( "./filtered/Output ##{@uid}-#{ Help.stamp }", filtered)  	       # Drop the filtered into a file

                run_tag = "Run " + runs.to_s
                server_tag = "Server " + @server

                Help.stats[[server_tag, run_tag].join(" ")] = filter.test_state		     # Catch the fail state for stats

                runs = runs + 1

                end

            }

          }

        }

      }

    }


    File.write( "./reports/Output ##{@uid}-#{ Help.time }", $stats.to_s )

    p Help.stats.to_s

    end

  end

end
