# Mockstarter

Mockstarter. Redis backed mini kickstarter.

## Installation

Add this line to your application's Gemfile:

Git clone this repo
```ruby
git clone https://github.com/shannonrdunn/Mockstarter
```

install gem dependencies
```bash
bundle
```

Run the rake command to build and install the gem, from the root of the git repo.
```bash
bundle exec rake install
```

This application requires redis to be somewhere. It's the mockstarter brain. Export the redis url as a env variable.

```
export MOCKSTARTER_BRAIN=redis://localhost:6379
```

## Usage

You are ready to start your project. Create it!

```
mockstarter project tardis 5000
```

Check status of your project

```
mockstarter list Tardis
```

Back a project.
```
back ryan california_water 4111111111111111 50
```

Run report on a user. See who they backed.
```
backer aurore
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To run the unit tests, run `bundle exec rake spec`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shannonrdunn/mockstarter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.
