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

  $logger = Logger.new(STDOUT)									# New logger at the module level
  $logger.formatter = proc{ |severity, datetime, progname, msg| puts msg }			# Fish out the error message only

  def self.log
    $logger
  end

  $stats = {}

  class Cups

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

#      @tests = ['test1', 'test2', 'test3']
#      @servers = ['avanboxel', 'qa-eris']
#      @options = {}
#      @file = ''
#      @errorlevel = 0                                                       # Fatals
#      @times = 3                                                           # By default, if you don't specify repetitions, there's just three.

      @options = Trollop::options do
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

     def self.err(message)

       $logger.error(message)

     end

     def self.warn(message)

       $logger.warn(message)

     end

     def self.info(message)

       $logger.info(message)

     end

     def self.fatal

       $logger.fatal( "FATAL: " + message + " EXITING.")

     end


      if (@errorlevel.to_s == '2')
         $logger.level = Logger::WARN
      elsif (@errorlevel.to_s == '1')
         $logger.level = Logger::ERROR
      elsif (@errorlevel.to_s == '0')
         $logger.level = Logger::FATAL
      elsif (@errorlevel == NIL)
         $logger.level = Logger::FATAL
      else
         $logger.level = Logger::FATAL
         $logger.fatal("Unknown error level setting attempted. Exiting.")
      end

      $logger.info("@errorlevel was set to #{ @errorlevel }")
      $logger.info("logger level was set to #{ $logger.level }")

      # The hierarchy here is going to be default file, then specified file,
      # then command line options if specified. That way, we can run Octy with just
      # the default options we want.
      # TODO: add this information to the helpfile that trollop does.
      #
      # MAYBE: Consider highline for a later 'interactive specification' option, though?

    end

  end

  class Cuisinart

    include CommandLineReporter

    attr_accessor :test_state

    @lines = ''
    $test_state = "success"

      def rj(digit)					# sub for right justifying with zeros on date numbers
        return digit.to_s.rjust(2, "0")
      end

      def err(message)

        $logger.error(message)

      end

      def warn(message)

        $logger.warn(message)

      end

      def info(message)

        $logger.info(message)

      end

      def fatal

        $logger.fatal( "FATAL: " + message + " EXITING.")

      end

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

        $test_state = "success"

        result.each_line { |line|

        line = line.gsub(/^.{,35}/, '')         # Strip timestamp and epoch and blank space after
        index = index + 1

        if (index <= 9)				# Ignore the first nine lines.
          next
        elsif (line.match(/^\W{4}\w/))          # Ignore most lines with 4 whitespaces in front.
          info("Skipping #{ line }.")
        elsif (error)             		# If there's an error, catch the lines in the diff.
          processed.push(line)
          info("Caught because error flagging.")
        elsif (
         line.match(/^\W{4}\w/) and
         previous.match(/^\W{6}\w/) )  		# If we're at the start of an error, start recording and catch the line before.
          error = false
          processed.push(previous)
          processed.push(line)
          info("Caught an ending line and previous.")
        elsif (
         line.match(/^\W{6}\w/) and
         previous.match(/^\W{4}\w/) ) 		# If we're at the end of an error, stop recording.
          error = true
          $test_state = "failure"
          processed.push( " >>>> FAILED AT <<<< " )
          processed.push(previous)
          processed.push(line)
          info("Caught a beginning line.")
        elsif (line.match(/^\W{6}\w/))          # Catch any lines that happen to be indented enough to be error or diff.
          processed.push(line)
          info("Catching an error because of indentation.")
        elsif (line.match(/^\w/))           	# Catch any lines that haven't got any indentation.
          processed.push(line)
          info("Catching a line because of lack of indentation.")
        end

        previous = line				# Next line. Store the last one.

      }


      puts "Processed is: "
      puts processed

      t = Time.new
      time = [ [ rj(t.day), rj(t.mon), t.year ].join("-"), [ rj(t.hour), rj(t.min), rj(t.sec) ].join("=") ].join(" ")

      puts "Processed at: #{ time }"

      report = processed.join("")

      report

    end

  end

  class Hopper

    attr_accessor :count, :servers, :tests, :browsers, :platforms, :versions, :stats

    def rj(digit)
      return digit.to_s.rjust(2, "0")
    end

    def initialize (options)          # A six-item hash with an integer (iteration count) and then five arrays
                                      # -- servers, tests, browsers, platforms, versions
      @o = options

      @count        = @o[:count]
      @servers      = @o[:servers]
      @tests        = @o[:tests]
      @browsers     = @o[:browsers]
      @platforms    = @o[:platforms]
      @versions     = @o[:versions]


      # create a timestamped directory for this batch of tests

    end

    def err(message)

      $logger.error(message)

    end

    def warn(message)

      $logger.warn(message)

    end

    def info(message)

      $logger.info(message)

    end

    def self.fatal

      $logger.fatal( "FATAL: " + message + " EXITING.")

    end

    def empty

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

                t = Time.new                                          	        # New timestamp for each run
                time = [ [ rj(t.day), rj(t.mon), t.year ].join("-"),			# Format for the report
                         [ rj(t.hour), rj(t.min), rj(t.sec) ].join("=") ].join(" ")

                # Pack up the vars into the executable string
                execstring = '/usr/local/bin/gless ' +
                             test + " " + server + " GE_BROWSER=" +
                             browser + ' GE_PLATFORM="' + platform + '"' + " GE_BROWSER_VERSION=" + version
                puts execstring
                result = %x( #{ execstring } 2>&1 )

                info( "Finished the executions." )

                File.write( "./raw/Output ##{@uid}-#{ time }", result) 		# Drop the raw output into a file
                result = result.gsub(/\e\[\d{1,2}m/, '')                       	# Strip formatting

                filter = Cuisinart.new()
                filtered = filter.run(result)

                File.write( "./filtered/Output ##{@uid}-#{ time }", filtered)  	# Drop the filtered into a file

                run_tag = "Run " + runs.to_s
                server_tag = "Server " + @server
                failstate = filter.test_state

                $stats[[server_tag, run_tag].join(" ")] = failstate		# Catch the fail state for stats

                # store the stat info here

                runs = runs + 1

                end

            }

          }

        }

      }

    }

    t = Time.new                                                    # New timestamp for each run
    time = [ [ rj(t.day), rj(t.mon), t.year ].join("-"),                    # Format for the report
           [ rj(t.hour), rj(t.min), rj(t.sec) ].join("=") ].join(" ")


    File.write( "./reports/Output ##{@uid}-#{ time }", $stats.to_s )

    p $stats.to_s

    end

  end

  end
