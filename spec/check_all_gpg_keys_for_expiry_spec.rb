#! /usr/bin/env ruby
#
# check_all_gpg_keys_for_expiry_spec
#
# DESCRIPTION:
#   This script will test check-all-gpg-keys-for-expiry script to ensure that it works properly.
#
# PLATFORMS:
#   Linux, Mac OS X
#
# DEPENDENCIES:
#   gem: spec_helper, check-all-gpg-keys-for-expiry
#
# USAGE:
#   rspec check_all_gpg_keys_for_expiry_spec.rb
#
# LICENSE:
#   Aditya Pahuja aditya.s.pahuja@gmail.com
#   Copyright (c) 2016 Crown Copyright
#   Released under the same terms as Crown (the MIT license); see LICENSE
#   for details.

require_relative 'spec_helper.rb'
require_relative '../bin/check-all-gpg-keys-for-expiry.rb'

# Stop CheckAllGpgKeysForExpiry from running while executing rspec
CheckAllGpgKeysForExpiry.disable_autorun

describe CheckAllGpgKeysForExpiry do
  context 'when testing the CheckAllGpgKeysForExpiry class' do
    before(:all) do
      @open3 = Open3
      @date = Date
      @check_gpg_expiry = CheckAllGpgKeysForExpiry.new
      @current_date = Date.new(2016, 10, 27)
      @p = ProcessStatus.new(true)

      @gpg_secret_key_1 = GPGKey.new('AAAAAAA111111111',
                                     KeyType::SECRET,
                                     Date.new(2016, 10, 5).to_time.to_i,
                                     Date.new(2020, 10, 5).to_time.to_i,
                                     'GPG Check <gpg.check@email.co.uk>')
      @gpg_secret_key_2 = GPGKey.new('AAAAAAA111111112',
                                     KeyType::SECRET,
                                     Date.new(2016, 9, 24).to_time.to_i,
                                     Date.new(2020, 9, 24).to_time.to_i,
                                     'GPG Check <gpg.check@email.co.uk>')
      @secret_keys = @gpg_secret_key_1.output + "\n" + @gpg_secret_key_2.output

      @gpg_public_key_1 = GPGKey.new('AAAAAAA111111111',
                                     KeyType::PUBLIC,
                                     Date.new(2016, 10, 5).to_time.to_i,
                                     Date.new(2020, 10, 5).to_time.to_i,
                                     'GPG Check <gpg.check@email.co.uk>')
      @gpg_public_key_2 = GPGKey.new('AAAAAAA111111112',
                                     KeyType::PUBLIC,
                                     Date.new(2016, 9, 24).to_time.to_i,
                                     Date.new(2020, 9, 24).to_time.to_i,
                                     'GPG Check <gpg.check@email.co.uk>')
      @public_keys = @gpg_public_key_1.output + "\n" + @gpg_public_key_2.output
    end

    describe '#fetch_collection_of_keys' do
      it 'returns no secret key' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@open3).to receive(:capture3) { ['', '', @p] }

        success, actuals = @check_gpg_expiry.fetch_collection_of_keys

        expect(actuals.count).to eq 0
        expect(success).to eq true
        expect(actuals.to_s).to eq '[]'
      end

      it 'returns a secret key' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { [@gpg_secret_key_1.output, '', @p] }

        success, actuals = @check_gpg_expiry.fetch_collection_of_keys

        expected_0 = Tool.output(@gpg_secret_key_1, 'OK', '1439')
        expect(actuals.count).to eq 1
        expect(success).to eq true
        expect(actuals[0].to_s).to eq expected_0
      end

      it 'returns two secret keys' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        success, actuals = @check_gpg_expiry.fetch_collection_of_keys

        expected_0 = Tool.output(@gpg_secret_key_1, 'OK', '1439')
        expected_1 = Tool.output(@gpg_secret_key_2, 'OK', '1428')
        expect(actuals.count).to eq 2
        expect(success).to eq true
        expect(actuals[0].to_s).to eq expected_0
        expect(actuals[1].to_s).to eq expected_1
      end

      it 'returns a public key' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { [@gpg_public_key_1.output, '', @p] }

        success, actuals = @check_gpg_expiry.fetch_collection_of_keys

        expected_0 = Tool.output(@gpg_public_key_1, 'OK', '1439')
        expect(actuals.count).to eq 1
        expect(success).to eq true
        expect(actuals[0].to_s).to eq expected_0
      end

      it 'returns two public keys' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        success, actuals = @check_gpg_expiry.fetch_collection_of_keys

        expected_0 = Tool.output(@gpg_public_key_1, 'OK', '1439')
        expected_1 = Tool.output(@gpg_public_key_2, 'OK', '1428')
        expect(actuals.count).to eq 2
        expect(success).to eq true
        expect(actuals[0].to_s).to eq expected_0
        expect(actuals[1].to_s).to eq expected_1
      end
    end

    describe '#run' do
      it 'returns OK message containing one of two secret keys which has 15 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 9) }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_secret_key_2, 'OK', '15')
        expected_1 = Tool.output(@gpg_secret_key_1, 'OK', '26')
        expected = expected_0 + "\n" + expected_1 + "\n"
        expect(actual).to eq(Tool.json_output(expected, 0))
      end

      it 'returns WARNING message containing one of two secret keys which has 14 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 10) }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_secret_key_2, 'WARNING', '14')
        expected_1 = Tool.output(@gpg_secret_key_1, 'OK', '25')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 1))
      end

      it 'returns WARNING message containing one of two secret keys which has 6 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 18) }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_secret_key_2, 'WARNING', '6')
        expected_1 = Tool.output(@gpg_secret_key_1, 'OK', '17')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 1))
      end

      it 'returns CRITICAL message containing one of two secret keys which has 5 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 19) }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_secret_key_2, 'CRITICAL', '5')
        expected_1 = Tool.output(@gpg_secret_key_1, 'OK', '16')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 2))
      end

      it 'returns CRITICAL message containing one of secret keys which has expired' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: true,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 25) }
        allow(@open3).to receive(:capture3) { [@secret_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_secret_key_2, 'CRITICAL', '-1')
        expected_1 = Tool.output(@gpg_secret_key_1, 'WARNING', '10')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 2))
      end

      it 'returns OK message containing one of two public keys which has 15 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 9) }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_public_key_2, 'OK', '15')
        expected_1 = Tool.output(@gpg_public_key_1, 'OK', '26')
        expected = expected_0 + "\n" + expected_1 + "\n"
        expect(actual).to eq(Tool.json_output(expected, 0))
      end

      it 'returns WARNING message containing one of two public keys which has 14 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 10) }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_public_key_2, 'WARNING', '14')
        expected_1 = Tool.output(@gpg_public_key_1, 'OK', '25')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 1))
      end

      it 'returns WARNING message containing one of two public keys which has 6 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 18) }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_public_key_2, 'WARNING', '6')
        expected_1 = Tool.output(@gpg_public_key_1, 'OK', '17')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 1))
      end

      it 'returns CRITICAL message containing one of two public keys which has 5 days left' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 19) }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_public_key_2, 'CRITICAL', '5')
        expected_1 = Tool.output(@gpg_public_key_1, 'OK', '16')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 2))
      end

      it 'returns CRITICAL message containing one of public keys which has expired' do
        allow(@check_gpg_expiry).to receive(:config){
          {
            warning: 14,
            critical: 5,
            home_directory: '/root/.gnupg',
            gpg: '/usr/bin/gpg',
            use_secret_key: false,
            do_not_display_json_message: false
          }
        }
        allow(@date).to receive(:today) { Date.new(2020, 9, 25) }
        allow(@open3).to receive(:capture3) { [@public_keys, '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected_0 = Tool.output(@gpg_public_key_2, 'CRITICAL', '-1')
        expected_1 = Tool.output(@gpg_public_key_1, 'WARNING', '10')
        expected = expected_0 + "\n" + expected_1 + "\n"

        expect(actual).to eq(Tool.json_output(expected, 2))
      end

      it 'returns OK message containing no keys (empty string)' do
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { ['', '', @p] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected = 'There are no keys.'
        expect(actual).to eq(Tool.json_output(expected, 0))
      end

      it 'returns OK message containing no keys (null values)' do
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { [nil, nil, ProcessStatus.new(false)] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expected = 'There are no keys.'
        expect(actual).to eq(Tool.json_output(expected, 0))
      end

      it 'returns UNKNOWN message after failing to execute a command' do
        error_message = 'Failed to execute a command.'
        allow(@date).to receive(:today) { @current_date }
        allow(@open3).to receive(:capture3) { ['', error_message, ProcessStatus.new(false)] }

        note, level = @check_gpg_expiry.sort_keys
        actual = @check_gpg_expiry.generate_json_message(note, level)

        expect(actual).to eq(Tool.json_output(error_message, 3))
      end
    end
  end
end
