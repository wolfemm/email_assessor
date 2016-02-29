# ValidEmail2
[![Build Status](https://travis-ci.org/lisinge/email_assessor.png?branch=master)](https://travis-ci.org/lisinge/email_assessor)
[![Gem Version](https://badge.fury.io/rb/email_assessor.png)](http://badge.fury.io/rb/email_assessor)

A fork of of the wonderful [ValidEmail2](https://github.com/lisinge/valid_email2) by [Micke Lisinge](https://github.com/lisinge).

ValidEmail2:

* Validates emails with the help of the `mail` gem instead of some clunky regexp.
* Aditionally validates that the domain has a MX record.
* Optionally validates against a static [list of disposable email services](vendor/disposable_domains.txt).


### Why?

ValidEmail2 offers very comprehensive email validation, but it has a few pitfalls.

For starters, it loads the entire list of blacklisted/disposable email domains into memory from a YAML file. In a never ending battle against spam, loading such an extremely large (and ever-growing) array into memory is far from ideal. Instead, EmailAssessor reads a text file line-by-line.

Another pitfall is that subdomains are able to bypass the disposable and blacklist checks in ValidEmail2. EmailAssessor checks if a given domain *ends* with a blacklisted/disposable domain, preventing subdomains from masking an email that would otherwise be considered invalid.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "email_assessor"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install email_assessor

## Usage

### Use with ActiveModel

If you just want to validate that it is a valid email address:
```ruby
class User < ActiveRecord::Base
  validates :email, presence: true, email: true
end
```

To validate that the domain has a MX record:
```ruby
validates :email, email: { mx: true }
```

To validate that the domain is not a disposable email:
```ruby
validates :email, email: { disposable: true }
```

To validate that the domain is not blacklisted (under vendor/blacklisted_domains.txt):
```ruby
validates :email, email: { blacklist: true }
```

All together:
```ruby
validates :email, email: { mx: true, disposable: true }
```

> Note that this gem will let an empty email pass through so you will need to
> add `presence: true` if you require an email

### Use without ActiveModel

```ruby
address = EmailAssessor::Address.new("lisinge@gmail.com")
address.valid? => true
address.disposable? => false
address.valid_mx? => true
```

### Test environment

If you are validating `mx` then your specs will fail without an internet connection.
It is a good idea to stub out that validation in your test environment.
Do so by adding this in your `spec_helper`:
```ruby
config.before(:each) do
  allow_any_instance_of(EmailAssessor::Address).to receive(:valid_mx?) { true }
end
```

## Requirements

This gem requires Rails 3.2 or 4.0. It is tested against both versions using:
* Ruby-1.9
* Ruby-2.0
* Ruby-2.1
* Ruby-2.2
* JRuby-1.9

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
