# Sensu Plugins GPG

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-gpg.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-gpg)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-gpg.svg)](http://badge.fury.io/rb/sensu-plugins-gpg)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-gpg/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-gpg)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-gpg/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-gpg)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-gpg.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-gpg)

This plugin is used for monitoring GPG keys.

## Files

* bin/check-gpg-expiration.rb
* bin/check-all-gpg-keys-for-expiry.rb

## Usage

In a proper gem environment, plugins can be executed directly from the command line. If you want to check GPG keys' expiry dates, you can use the 'check-all-gpg-keys-for-expiry' plugin. This will only work for Ruby scripts. Scripts in other languages will still need to be called directly due to binstubs not being automatically created.

```
check-all-gpg-keys-for-expiry.rb -w 7 -c 2 -h ~/.gnupg --do-not-display-json-message
```

Depending on Ruby environment, you may need to call Ruby directly.

```
/opt/sensu/embedded/bin/ruby check-all-gpg-keys-for-expiry.rb -w 7 -c 2 -h ~/.gnupg --do-not-display-json-message
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sensu-plugins/sensu-plugins-gpg.
