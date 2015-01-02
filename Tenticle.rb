module Tenticle

  # We need to check the args for:
  # Verbose mode.
  # Error level. (This is complex, so we may need to use a strategy pattern for it)
  # Config file selection.

  class Cups

    # Cups provides Tenticle with grip. In this case, that means setting configuration
    # state and handling command line alterations for it.

    attr_accessor :file, :verbose, :errorlevel, :times, :list

    def initialize (args)

      # These define the basic configuration. They're altered by command line options.

      @tests = ['test1', 'test2', 'test3']
      @servers = ['avanboxel', 'qa-eris']
      @file = ''
      @verbose = false                  # Keep it quiet
      @errorlevel = 2                   # Fatals
      @times = 3                        # By default, if you don't specify repetitions, there's just three.

      args.each_with_index do |arg, count|

        if (arg == ('-f')) then
          err("Setting config filename as '#{ args[count+1] }'", 2)
          @file = args[count+1]

# Fix this functionality later, so that tests and servers tested can be specified
# on the command line.
#
#        elsif (arg == ('-s')) then
#          err("Servers specified as '#{ (args[count+1]).join(', ') }", 2)
#          @servers = args[count+1]
#
#        elsif (arg == ('-t')) then
#          err("Tests specified as '#{ (args[count+1]).join(', ') } ", 2)
#          @tests = args[count+1]

        elsif (arg == ('-v')) then
          err("Verbose on", 2)
          @verbose = true

        elsif (arg == ('-e')) then
          err("Setting errorlevel to #{ args[count+1] }", 2)
          @errorlevel = args[count+1]

        elsif (arg == ('-i')) then
          err("Setting iterations (#{ @times }) to #{ args[count+1] }", 2)
          @times = args[count+1]

        elsif (arg == args[-1]) then
          err("Hit the last argument, so we're popping out.", 2)
          next

        else

          err("Unidentified command line flags used.", 0)

        end

      end

      err("Command line arguments are: #{ args.join(" ") }", 2)

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
