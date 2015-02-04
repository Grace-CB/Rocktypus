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

  # @logger = Logger.new(STDOUT)

  class Cups

    attr_accessor :file, :time, :servers, :tests, :errorlevel, :platform, :browser, :version

    # require "logger"

    # Cups provides Tenticle with grip. In this case, that means setting configuration
    # state and handling command line alterations for it.

    @errorlevel = ''
    @tests = []
    @servers = []
    @options = []
    @file = ''
    @times = ''
    @@logger = Logger.new(STDOUT)

    @@logger.formatter = proc { |severity, datetime, progname, msg| puts msg }

    def initialize (args)

      # These define the basic configuration. They're altered by command line options.

      # @logger = Logger.new(STDOUT)

#      @tests = ['test1', 'test2', 'test3']
#      @servers = ['avanboxel', 'qa-eris']
#      @options = {}
#      @file = ''
#      @errorlevel = 0                                                       # Fatals
#      @times = 3                                                           # By default, if you don't specify repetitions, there's just three.

      @options = Trollop::options do
        opt :file, "Filename", :type => :string, :default => 'cfg.yml'      			         # Default config is 'cfg.yml'
        opt :iterations, "Iterations", :type => :integer, :default => 3     			         # Default number of iterations is 3
        opt :servers, "Servers", :type => :strings, :default => ['qa-eris', 'qa-janus'] 	 	 # Defaults to qa-eris
        opt :tests, "Tests", :type => :strings, :default => ['very_tiny_perf_test']		         # Defaults to u937
        opt :errorlevel, "Error level", :type => :integer, :default => 0    			         # Defaults to 0 (fatals only)
        opt :platform, "OS", :type => :string, :default => 'Windows 8'      			         # Defaults to Win8
        opt :browser, "Browser", :type => :string, :default => 'firefox'    			         # Defaults to firefox
        opt :browserversion, "Browser version", :short => "-r",             			         # Defaults to 33
          :type => :string, :default => '33'
      end

      @file = @options[:file]
      @times = @options[:iterations]
      @servers = @options[:servers]
      @tests = @options[:tests]
      @errorlevel = @options[:errorlevel]
      @platform = @options[:platform]
      @browser = @options[:browser]
      @version = @options[:version]

      @@logger.info("@errorlevel was set to #{ @errorlevel }")

      if (@errorlevel.to_s == '2') 
         @@logger.level = Logger::WARN
      elsif (@errorlevel.to_s == '1')
         @@logger.level = Logger::ERROR
      elsif (@errorlevel.to_s == '0')
         @@logger.level = Logger::FATAL
      elsif (@errorlevel == NIL)
         @@logger.level = Logger::FATAL
      else
         @@logger.level = Logger::FATAL
         @@logger.fatal("Unknown error level setting attempted. Exiting.")
      end

      @@logger.info("logger level was set to #{ @@logger.level }")

      # The hierarchy here is going to be default file, then specified file,
      # then command line options if specified. That way, we can run Octy with just
      # the default options we want.
      # TODO: add this information to the helpfile that trollop does.
      #
      # MAYBE: Consider highline for a later 'interactive specification' option, though?

    end

    def err(message)

      @@logger.error(message)

    end

    def warn(message)

      @@logger.warn(message)

    end

    def info(message)

      @@logger.info(message)

    end

    def fatal

      @@logger.fatal( "FATAL: " + message + " EXITING.")

    end

  end

  class Cuisinart

    include CommandLineReporter
    a = ''

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

        line = line.gsub(/^.{,35}/, '')         # Strip timestamp and epoch and blank space after
        index = index + 1

        if (index <= 9)
    next
        elsif (line.match(/^\W{4}\w/))          # Ignore most lines with 4 whitespaces in front.
          @a.info("Skipping #{ line }.")
        elsif (error)             # If there's an error, catch the lines in the diff.
          processed.push(line)
          @a.info("Caught because error flagging.")
        elsif (line.match(/^\W{4}\w/) and previous.match(/^\W{6}\w/)) # If we're at the start of an error, start recording and catch the line before.
          error = FALSE
          processed.push(previous)
          processed.push(line)
          @a.info("Caught an ending line and previous.")
        elsif (line.match(/^\W{6}\w/) and previous.match(/^\W{4}\w/)) # If we're at the end of an error, stop recording.
          error = TRUE
          processed.push( " >>>> FAILED AT <<<< " )
          processed.push(previous)
          processed.push(line)
          @a.info("Caught a beginning line.")
        elsif (line.match(/^\W{6}\w/))          # Catch any lines that happen to be indented enough to be error or diff.
          processed.push(line)
          @a.info("Catching an error because of indentation.")
        elsif (line.match(/^\w/))           # Catch any lines that haven't got any indentation.
          processed.push(line)
          @a.info("Catching a line because of lack of indentation.")
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

    def initialize (options)          # A six-item hash with an integer (iteration count) and then five arrays
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

                tstamp = Time.new                                          	# New timestamp for each run
                time = [ [ t.day, t.mon, t.year ].join("-"),			# Format for the report
                         [ t.hour, t.min, t.sec ].join("-") ].join(" ")
                uid = %x( ruby uid.rb )             				# New UID for each run

                # Pack up the vars into the executable string
                execstring = '/usr/bin/gless #{ test } #{ server } GE_BROWSER="#{ browser }" GE_PLATFORM="#{ platform }" GE_BROWSER_VERSION="#{ version }"'
                # result = %x( #{execstring} 2>&1 )

                # File.write( "./raw/Output UID-#{uid}--TIME-#{ time }", result) # Drop the output into a file
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

  end
