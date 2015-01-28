module Tenticle

require "highline/import"
require "logger"
require "trollop"

  # trollop options settable at command line include:
  # (S)ervers to test on
  # (T)ests to run
  # (I)terations of each test
  # (E)rrorlevel
  # (B)rowser flavor
  # b(R)owser version

  class Cups

    # Cups provides Tenticle with grip. In this case, that means setting configuration
    # state and handling command line alterations for it.

    @errorlevel = ''
    @tests = []
    @servers = []
    @options = []
    @file = ''
    @times = ''

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
        opt :servers, "Servers", :type => :strings, :default => ['qa-eris', 'qa-janus'] 	 # Defaults to qa-eris
        opt :tests, "Tests", :type => :strings, :default => ['very_tiny_perf_test']		     # Defaults to u937
        opt :errorlevel, "Error level", :type => :integer, :default => 0    			         # Defaults to 0 (fatals only)
        opt :platform, "OS", :type => :string, :default => 'Windows 8'      			         # Defaults to Win8
        opt :browser, "Browser", :type => :string, :default => 'firefox'    			         # Defaults to firefox
        opt :browserversion, "Browser version", :short => "-r",             			         # Defaults to 33
          :type => :string, :default => '33'
      end

      err( "Command line arguments are: #{ p @options }", 2 )
      @file = @options[:file]
      @times = @options[:iterations]
      @servers = @options[:servers]
      @tests = @options[:tests]
      @errorlevel = @options[:errorlevel]
      @platform = @options[:platform]
      @browser = @options[:browser]
      @version = @options[:version]

      # The hierarchy here is going to be default file, then specified file,
      # then command line options if specified. That way, we can run Octy with just
      # the default options we want.
      # TODO: add this information to the helpfile that trollop does.
      #
      # MAYBE: Consider highline for a later 'interactive specification' option, though?

    end


#TODO: this probably could be streamlined a lot

    def prefix (prefix, message)
      yield(prefix, message)
    end

    def ize(desc, message)
      desc = desc + ": "
      prefix(desc, message) { |a, b| a + b }
    end

    def errorize (message)
      puts ize("Error", message)
    end

    def warnize (message)
      if ( @errorlevel >= 1 )
        puts ize("Warning", message)
      end
    end

    def diagnize (message)
      if ( @errorlevel >= 2 )
        puts ize("Diagnostics", message)
      end
    end

    def err (message, level)

      if (level == 0)
        "#{errorize(message)}  >>[FATAL. QUITTING.]<<  "
        exit

      elsif (level == 1)

        if (@errorlevel >= 1)
          warnize(message)
        end

      elsif (level == 2)

        if (@errorlevel >= 2)
          diagnize(message)
        end

      else

        err("Unknown error ", 0)

      end

    end

  end

end
