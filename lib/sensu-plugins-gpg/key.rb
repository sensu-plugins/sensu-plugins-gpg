#! /usr/bin/env ruby
#
# check-all-gpg-keys-for-expiry
#
# DESCRIPTION:
#   The Key class stores information about the key. It has id, expiry date,
#   description, level and number of days left
#
# LICENSE:
#   Aditya Pahuja aditya.s.pahuja@gmail.com
#   Copyright (c) 2016 Crown Copyright
#   Released under the same terms as Crown (the MIT license); see LICENSE
#   for details.
#
class Key
  attr_accessor :id, :expiry, :description, :level, :num_of_days_left

  def initialize(id, expiry)
    @id = id
    @expiry = expiry
  end

  # Return the expiry date if @expiry is specified otherwise return
  # 'N/A'
  def display_expiry_date
    @expiry.nil? ? 'N/A' : Time.at(@expiry.to_i).to_datetime.to_s
  end

  # Return the number of days left if @num_of_days_left is specified
  # otherwise return 'N/A'
  def display_num_of_days_left
    @num_of_days_left == Integer::MAX ? 'N/A' : @num_of_days_left.to_s
  end

  # Return the meaningful information about the instance of Key
  def inspect
    'Id: ' + @id.to_s +
      ', Expires on: ' + display_expiry_date +
      ', Level: ' + map_number_to_word_level(@level) +
      ', Number of days left to expire: ' + display_num_of_days_left +
      ', Description: ' + @description % self
  end

  # Print the instance of Key's details in a nice format
  def to_s
    'Id: ' + @id.to_s +
      ', Expires on: ' + display_expiry_date +
      ', Level: ' + map_number_to_word_level(@level) +
      ', Number of days left to expire: ' + display_num_of_days_left +
      ', Description: ' + @description % self
  end

  private

  # Return the meaningful word for a specified level
  def map_number_to_word_level(level)
    case level
    when 0
      'OK'
    when 1
      'WARNING'
    when 2
      'CRITICAL'
    when 3
      'UNKNOWN'
    end
  end
end
