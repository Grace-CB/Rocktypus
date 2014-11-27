module Tenticle

  # We need to check the args for:
  # Verbose mode.
  # Error level. (This is complex, so we may need to use a strategy pattern for it)
  # Config file selection.

  class Cups

    def init (args)

      max = 0
      list = Hash.new
      args.each_with_index do |arg, count|
        list[arg] = count+1
        max = count+1
      end

      puts "Max: #{ max }"

      x = 0

      while (max > x) do

      if (list[x] == ('-f')) then
        puts "Setting @@file to #{ list[x+1] }"
        @@file = list[x+1]
        x = x + 2
        next

      elsif (list[x] == ('-v')) then
        puts "Setting @@verbose to true"
        @@verbose = true

      elsif (list[x] == ('-e')) then
        puts "Setting @@errorlevel to #{ list[x+1] }"
        @@errorlevel = list[x+1]
        x = x + 2
        next

      elsif (list[x] == ('-t')) then
        puts "Setting @@times to #{ list[x+1] }"
        @@times = list[x+1]
        x = x + 2
        next

      else

        next

      end

    end

  end

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
      puts errorize(message)
      puts "  >>[Fatal error. Quitting.]<<  "
      exit

    elsif (level == 1) then
      puts warnize(message)

    elsif (level == 2) then
      puts diagnize(message)

    else
      quit
    end

  end

end

end