#! /usr/bin/env ruby
#
# check-all-gpg-keys-for-expiry
#
# DESCRIPTION:
#   The Integer class provides maximum and minimum integer.
#
# LICENSE:
#   Aditya Pahuja aditya.s.pahuja@gmail.com
#   Copyright (c) 2016 Crown Copyright
#   Released under the same terms as Crown (the MIT license); see LICENSE
#   for details.
#
class Integer
  # Number of bytes
  N_BYTES = [42].pack('i').size

  # Number of bits
  N_BITS = N_BYTES * 8

  # Maximum number for integer
  MAX = 2**(N_BITS - 2) - 1

  # Minimum number for integer
  MIN = -MAX - 1
end
