module Tenticle

require "highline/import"
require "logger"
require "trollop"

  # trollop options settable at command line include:
  # (S)ervers to test on
  # (T)ests to run
  # (I)terations of each test
  # (E)rrorlevel
  # (V)erbose mode
  # (B)rowser flavor
  # b(R)owser version

  class Cups

    # Cups provides Tenticle with grip. In this case, that means setting configuration
    # state and handling command line alterations for it.

    attr_accessor :options

    def initialize (args)

      # These define the basic configuration. They're altered by command line options.

#      @tests = ['test1', 'test2', 'test3']
#      @servers = ['avanboxel', 'qa-eris']
#      @options = {}
#      @file = ''
#      @verbose = false                                                     # Keep it quiet
      @errorlevel = 2                                                       # Fatals
#      @times = 3                                                           # By default, if you don't specify repetitions, there's just three.

      @options = Trollop::options do
        opt :file, "Filename", :type => :string, :default => 'cfg.yml'      # Default config is 'cfg.yml'
        opt :iterations, "Iterations", :type => :integer, :default => 3     # Default number of iterations is 3
        opt :servers, "Servers", :type => :strings, :default => ['qa-eris'] # Defaults to qa-eris
        opt :tests, "Tests", :type => :strings, :default => ['u937']        # Defaults to u937
        opt :errorlevel, "Error level", :type => :integer, :default => 2    # Defaults to 2
        opt :platform, "OS", :type => :string, :default => 'Windows 8'       # Defaults to Win8
        opt :browser, "Browser", :type => :string, :default => 'firefox'    # No default
        opt :browserversion, "Browser version", :short => "-r",             # No default
          :type => :string, :default => '33'
      end

      puts "Command line arguments are: #{ p @options }"
      @errorlevel = @options[:errorlevel]

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
      ize("Error", message)
    end

    def warnize (message)
      ize("Warning", message)
    end

    def diagnize (message)
      ize("Diagnostics", message)
    end

    def err (message, level)

      if (level == 0) then
        puts "#{errorize(message)}  >>[FATAL. QUITTING.]<<  "
        exit

      elsif (level == 1) then

        if (@errorlevel >= 1) then puts warnize(message) end

      elsif (level == 2) then

        if (@errorlevel >= 2) then puts diagnize(message) end

      else

        err("Error handling error ", 0)

      end

    end

  end

end
