# Vseries

![](https://github.com/catks/vseries/workflows/Ruby/badge.svg?branch=master)

Vseries is a micro library to work with semantic version tags.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'vseries'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vseries

## Usage

```ruby

require 'vseries'

version_1 = Vseries::SemanticVersion.new('1.1.2')
version_2 = Vseries::SemanticVersion.new('1.1.2-rc.2')

version1.to_s # => 1.1.2

version_1 == Vseries::SemanticVersion.new('1.1.2') # => true
version_1 < version_2  # => false
version_1 <= version_2 # => false
version_1 > version_2  # => true
version_1 >= version_2  # => true

version_1.up(:patch).to_s # => '1.1.3'
version_1.up(:minor).to_s # => '1.2.0'
version_1.up(:major).to_s # => '2.0.0'

version_2.up(:patch).to_s # => '1.1.3-rc.1'
version_2.up(:minor).to_s # => '1.2.0-rc.1'
version_2.up(:major).to_s # => '2.0.0-rc.1'

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/catks/vseries.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
