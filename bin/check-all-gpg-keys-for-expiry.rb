#! /usr/bin/env ruby
#
# check-all-gpg-keys-for-expiry
#
# DESCRIPTION:
#   This script will check all keys' expiry dates and generate JSON message or output
#   the string "CheckAllGpgKeysForExpiry OK: ..." (like a Nagios plugin). JSON message can be
#   sent to Sensu client.
#
# OUTPUT:
#   plain text
#   Defaults: CRITICAL if a key is about to expire in 5 days
#             WARNING if a key is about expire in 14 days
#             GPG home directory is /root/.gnupg
#             GPG executable binary is located under /usr/bin/gpg
#             It checks secret keys
#             It displays JSON message
#
# PLATFORMS:
#   Linux, Mac OS X
#
# DEPENDENCIES:
#   gem: sensu-plugin, csv, open3, date, time
#   GPG package
#
# USAGE:
#   check-all-gpg-keys-for-expiry.rb -w 7 -c 2 -h ~/.gnupg -e /usr/local/bin/gpg
#    --do-not-display-json-message --use-secret-key
#
# LICENSE:
#   Aditya Pahuja aditya.s.pahuja@gmail.com
#   Copyright (c) 2016 Crown Copyright
#   Released under the same terms as Crown (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-gpg'
require 'sensu-plugin/check/cli'
require 'csv'
require 'open3'
require 'date'
require 'time'

# == Description
#
# The CheckAllGpgKeysForExpiry class fetches all GPG keys, check their expiry dates and send
# appropriate alerts to Sensu
class CheckAllGpgKeysForExpiry < Sensu::Plugin::Check::CLI
  option :warning,
         short: '-w NUMBER_OF_DAYS_LEFT_TO_TRIGGER_ALERT',
         long: '--warning NUMBER_OF_DAYS_LEFT_TO_TRIGGER_ALERT',
         proc: proc(&:to_i),
         default: 14,
         description: 'The minimum number of days left to trigger a warning alert'

  option :critical,
         short: '-c NUMBER_OF_DAYS_LEFT_TO_TRIGGER_ALERT',
         long: '--critical NUMBER_OF_DAYS_LEFT_TO_TRIGGER_ALERT',
         proc: proc(&:to_i),
         default: 5,
         description: 'Minimum number of days left to trigger a critical alert'

  option :home_directory,
         short: '-h GPG_HOME_DIR',
         long: '--home-directory GPG_HOME_DIR',
         default: '/root/.gnupg',
         description: 'Location of GPG home directory',
         required: true

  option :gpg,
         short: '-e GPG_EXECUTABLE_PATH',
         long: '--execute GPG_EXECUTABLE_PATH',
         default: '/usr/bin/gpg',
         description: 'Location of binary executable file (gpg)'

  option :use_secret_key,
         short: '-s',
         long: '--use-secret-key',
         description: 'Check secret key instead of public key',
         boolean: true

  option :do_not_display_json_message,
         short: '-d',
         long: '--do-not-display-json-message',
         description: 'Display JSON message instead of sending it to Sensu',
         boolean: true

  def initialize
    super
  end

  # Return the number of days since epoch from a given epoch
  def self.days_since_epoch(e)
    epoch = Date.new(1970, 1, 1)
    d = Time.at(e).to_date
    (d - epoch).to_i
  end

  # Return --list-key if 'use_secret_key' is false otherwise
  # return --list-secret-key
  def key_type_option
    if !config[:use_secret_key]
      '--list-key'
    else
      '--list-secret-key'
    end
  end

  # Return all GPG keys' details by executing the GPG command
  def fetch_all_gpg_keys
    args = ['--with-colons', '--fixed-list-mode', '--lock-never', key_type_option]
    gpg_cmd = [config[:gpg] + " --homedir #{config[:home_directory]}"] + args

    _cmd_out, _cmd_err, _status = Open3.capture3 gpg_cmd.join(' ')
  end

  # Set the key's level to the appropriate level by checking its number of days left
  def update_key_level(key)
    num_of_days_left = key.num_of_days_left
    case num_of_days_left.to_s
    when /^-\d+$/
      key.level = 2
    when /^\d+$/
      return key.level = 0 if num_of_days_left > config[:warning]
      return key.level = 2 if num_of_days_left <= config[:critical]
      return key.level = 1
    else
      return key.level = 3
    end
  end

  # Return the number of days left using key's expiry date and today date
  def calculate_num_of_days_left(key, today_epoch)
    CheckAllGpgKeysForExpiry.days_since_epoch(key.expiry.to_i) - CheckAllGpgKeysForExpiry.days_since_epoch(today_epoch)
  end

  # Populate key's num of days left and its level
  def populate_key_num_of_days_left_and_level(key, today_epoch)
    if !key.expiry.nil?
      key.num_of_days_left = calculate_num_of_days_left(key, today_epoch)
      update_key_level(key)
    else
      key.num_of_days_left = Integer::MAX
      key.level = 0
    end
  end

  # Return pub if 'use_secret_key' is false otherwise
  # return sec
  def choose_key_type
    if !config[:use_secret_key]
      'pub'
    else
      'sec'
    end
  end

  # Return a collection of keys
  def create_a_collection_of_keys(keys_details)
    today_epoch = Date.today.to_time.to_i
    keys = []
    found_key = false
    key = nil
    key_type = choose_key_type
    CSV.parse(keys_details, col_sep: ':') do |row|
      current_key_type = row[0]
      if current_key_type == key_type
        key = Key.new(row[4], row[6])
        populate_key_num_of_days_left_and_level(key, today_epoch)
        found_key = true
      elsif found_key && current_key_type == 'uid'
        key.description = row[9]
        keys.push key
        found_key = false
      end
    end
    keys
  end

  # Run the GPG command to fetch all keys
  def fetch_collection_of_keys
    cmd_out, cmd_err, status = fetch_all_gpg_keys
    if status.success?
      [true, create_a_collection_of_keys(cmd_out)]
    else
      [false, cmd_err]
    end
  end

  # Return a generated JSON message using note and status
  def generate_json_message(note, status)
    hash = {
      name: self.class.name,
      output: (note.nil? ? 'Unknown, Empty Message?' : note),
      status: status
    }
    JSON.generate(hash)
  end

  # Return a note and an appropriate alert level after sorting keys using
  # their number of days left in ascending order
  def sort_keys
    success, output = fetch_collection_of_keys
    if success && output.count > 0
      note = ''
      output.sort! { |key1, key2| key1.num_of_days_left <=> key2.num_of_days_left }
      output.each do |key|
        note += key.to_s + "\n"
      end
      return note, output[0].level
    elsif success && output.count == 0
      return 'There are no keys.', 0
    elsif output.nil?
      return 'There are no keys.', 0
    else
      return output, 3
    end
  end

  # Return false with error message and its level if GPG executable binary file or its
  # home directory does not exist otherwise return true
  def validate_gpg_and_home_directory
    unless File.exist?(config[:gpg])
      return false, 'GPG executable binary file [' + config[:gpg] + '] does not exist.', 2
    end
    unless File.exist?(config[:home_directory])
      return false, 'GPG home directory [' + config[:home_directory] + '] does not exist.', 2
    end
    [true, '', 0]
  end

  # Send an appropriate alert level to Sensu using a specified level
  def select_appropriate_alert_level(level)
    if level == 0
      ok
    elsif level == 1
      warning
    elsif level == 2
      critical
    else
      unknown
    end
  end

  # Get all keys, sort them using their number of days left in ascending order
  # and then display JSON message or send the message to Sensu
  def run
    success, note, level = validate_gpg_and_home_directory
    note, level = sort_keys if success
    if !config[:do_not_display_json_message]
      puts generate_json_message(note, level)
    else
      message note
      select_appropriate_alert_level(level)
    end
    exit
  end

  # Provide an option to disable autorun
  def self.disable_autorun
    @@autorun = false
  end
end
