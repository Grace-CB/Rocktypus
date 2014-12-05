module Tenticle

  # We need to check the args for:
  # Verbose mode.
  # Error level. (This is complex, so we may need to use a strategy pattern for it)
  # Config file selection.

  class Cups

      attr_accessor :file, :verbose, :errorlevel, :times, :list

#FIXME: this has a non termination error

    def initialize (args)

      # These define the basic configuration. They're altered by command line options.

      file = 'default.yaml'             # #TODO: Create a self-creator if default.yaml doesn't exist
      verbose = false                   # Keep it quiet
      @errorlevel = 2                   # Fatals
      @times = 2                        # By default, if you don't specify repetitions, there's just two.
      @list = []                        # Holds all the incoming arguments for Octypus.

      args.each_with_index do |arg, count|

      @list[count] = arg

        if (arg == ('-f')) then
          puts "Setting config filename as #{ list[count+1] }"
          @file = list[count+1]

        elsif (list[count] == ('-v')) then
          puts "Setting verbose to true"
          verbose = true

        elsif (list[count] == ('-e')) then
          puts "Setting errorlevel to #{ list[count+1] }"
          @errorlevel = list[count+1]

        elsif (list[count] == ('-t')) then
          puts "Setting times to #{ list[count+1] }"
          @times = list[count+1]

        else

        end

      end

      puts "Max: #{ @max }"
      puts @list.join(" ")



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
      ize("Error: ", message)
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
        puts warnize(message)

      elsif (level == 2) then
        puts diagnize(message)

      else

        puts "Somehow we fell off the thing. You got me, bub."

      end

    end

  end

end
