# Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

### Breaking Changes
- removed ruby `< 2.3` support as they are EOL (@majormoses)
- bumped development dependency of `bundler` from `~> 1.7` to `~> 2.0` which required dropping EOL versions of ruby (@majormoses) (@dependabot)


## [2.0.0]
### Breaking Change
- bumped requirement of `sensu-plugin` to [2.0](https://github.com/sensu-plugins/sensu-plugin/blob/master/CHANGELOG.md#v200---2017-03-29) (@majormoses)

### Added
- added scripts `check-all-gpg-keys-for-expiry.rb` and its spec script `check_all_gpg_keys_for_expiry_spec.rb`. (@adityapahuja)

### Changed
- moved spec_helper.rb from test to spec folder for consistency. (@adityapahuja)
- updated spec_helper.rb to provide classes and tools for testing check-all-gpg-keys-for-expiry. (@adityapahuja)
- updated license to include Crown Copyright. (@adityapahuja)
- updated readme to provide details on newly added scripts. (@adityapahuja)
- updated version.rb to include comments. (@adityapahuja)

## [1.0.0] -  2017-07-15
### Added
- Ruby 2.3.0 support
- Ruby 2.4.1 support

### Breaking Changes
- Drop Ruby 1.9.3 support

## [0.0.4] - [2015-07-14]
### Changed
- updated docmumentation links in README and CHANGELOG
- removed unused tasks from rakefile
- put deps in alpha order in rakefile and gemspec

### Fixed
- binstubs are now only created for ruby files

## [0.0.3] - [2015-07-14]
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - [2015-06-02]
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - [2015-04-30]
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/2.0.0...HEAD
[2.0.0]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/0.0.4...1.0.0
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-gpg/compare/0.0.1...0.0.2
