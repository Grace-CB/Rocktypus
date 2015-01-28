#!/usr/bin/env ruby

require 'pstore'

last = PStore.new("last_uid")

uid = ''

uid = last.transaction { last.fetch(:uid, "A00A00A00" ) }

  # uid = 'Z99Z99Z97'                            # remove once we have the troubleshooting fixed

  # puts uid

  tokens = uid.split('')

  ( letter1, digit1, digit2,
    letter2, digit3, digit4,
    letter3, digit5, digit6 ) = tokens         # lX = letter in X position, dX = digit in X position

  # Increment the last digit.

  if (digit6.to_i < 9)

    digit6 = digit6.to_i + 1

  else (digit6.to_i == 9)

    digit6 = '0'
    digit5 = digit5.to_i + 1

  end

  # Check to see if the next digit is rolling over.

  if (digit5.to_i == 10)

    digit5 = 0
    # puts "letter 3 is #{ letter3.ord }"
    letter3 = letter3.ord + 1
    letter3 = letter3.chr
    # puts "letter 3 is #{ letter3 }"

  end

  # Check to see if the letter is rolling over.

  if (letter3 == "[")

    letter3 = "A"
    digit4 = digit4.to_i + 1

  end

  if (digit4 == 10)

    digit4 = 0
    digit3 = digit3.to_i + 1

  end

  if (digit3 == 10)

    digit3 = 0
    # puts "letter 2 is #{ letter2.ord }"
    letter2 = letter2.ord + 1
    letter2 = letter2.chr
    # puts "letter 2 is #{ letter2 }"

  end

  if (letter2 == "[")

    letter2 = "A"
    digit2 = digit2.to_i + 1

  end

  if (digit2 == 10)

    digit2 = 0
    digit1 = digit1.to_i + 1

  end

  if (digit1 == 10)

    digit1 = 0
    # puts "letter 1 is #{ letter1.ord }"
    letter1 = letter1.ord + 1
    letter1 = letter1.chr
    # puts "letter 1 is #{ letter1 }"

  end

  uid = [ letter1, digit1, digit2,
          letter2, digit3, digit4,
          letter3, digit5, digit6 ].join('')

  if (uid == "[00A00A00")

    uid = 'A00A00A00'

  end

puts uid

last.transaction do

  last[:uid] = uid

end