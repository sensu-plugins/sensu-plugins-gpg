#! /usr/bin/env ruby
#
# spec_helper
#
# DESCRIPTION:
#   This script provides classes and tools for testing check-all-gpg-keys-for-expiry.
#
# PLATFORMS:
#   Linux, Mac OS X
#
# DEPENDENCIES:
#   gem: json, ruby-enum
#
# LICENSE:
#   Aditya Pahuja aditya.s.pahuja@gmail.com
#   Copyright (c) 2016 Crown Copyright
#   Released under the same terms as Crown (the MIT license); see LICENSE
#   for details.

require 'json'
require 'ruby-enum'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start

class ProcessStatus
  attr_reader :status

  def initialize(status)
    @status = status
  end

  def success?
    status
  end
end

class KeyType
  include Ruby::Enum

  define :PUBLIC, 'public'
  define :SECRET, 'secret'
end

class GPGKey
  attr_reader :id, :type, :beginning_date, :expiry_date, :description

  def initialize(id, type, beginning_date, expiry_date, description)
    @id = id
    @type = type
    @beginning_date = beginning_date
    @expiry_date = expiry_date
    @description = description
  end

  def display_secret_key
    'sec::4096:1:' + id + ':' + beginning_date.to_s + ':' + expiry_date.to_s + ":::::::::\n"\
      'uid:::::::ABCDEF1234567890123456789012345678901234::' + description + ":\n"\
      'ssb::4096:1:0123456789ABCDEF:1475674022::::::::::'
  end

  def display_public_key
    'pub:-:4096:1:' + id + ':' + beginning_date.to_s + ':' + expiry_date.to_s + "::-:::scESC:\n"\
      'uid:-::::' + expiry_date.to_s + '::ABCDEF1234567890123456789012345678901234::' + \
      description + ":\n"\
      'sub:-:4096:1:1234567890ABCDEF:' + beginning_date.to_s + ':' + expiry_date.to_s + ':::::e:'
  end

  def output
    if @type == KeyType::SECRET
      display_secret_key
    else
      display_public_key
    end
  end
end

class Tool
  def self.output(key, level, num_of_days_left)
    @output =
      'Id: ' + key.id + ', '\
      'Expires on: ' + Time.at(key.expiry_date).to_datetime.to_s + ', '\
      'Level: ' + level + ', '\
      'Number of days left to expire: ' + num_of_days_left.to_s + ', '\
      'Description: ' + key.description
  end

  def self.json_output(note, status)
    hash = {
      name: 'CheckAllGpgKeysForExpiry',
      output: (note.nil? ? 'Unknown, Empty Message?' : note),
      status: status
    }
    JSON.generate(hash)
  end
end
