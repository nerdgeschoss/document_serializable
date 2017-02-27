# DocumentSerializable

[![CircleCI](https://circleci.com/gh/nerdgeschoss/document_serializable/tree/master.svg?style=svg)](https://circleci.com/gh/nerdgeschoss/document_serializable/tree/master)

Serialize your object hierarchy in a document based style to your relational database via virtus.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'document_serializable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install document_serializable

## Usage

Define your model:

```bash
rails g model Invoice properties:jsonb:index
```

```ruby
class Address
  include Virtus.model

  attribute :name
  attribute :city
end

class Invoice < ApplicationRecord
  attribute address, Address
  attribute subject
end
```

Then initialize it with content and access attributes directly from your model:

```ruby
invoice = Invoice.new subject: "Pay me!", address: { name: "Jon Doe", city: "New York" }
invoice.address.name # Jon Doe
invoice.subject # Pay me!
invoice.save!
```

This works for all models that have a serialized attribute named `properties` (e.g. json column in MySQL or jsonb in Postgres).

You can also query for properties (in Postgres):

```ruby
Invoice.where("properties @> ?", { address: { city: "New York" } }.to_json)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Alex/document_serializable.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
