# Guard::RSpectacle [![Build Status](https://secure.travis-ci.org/netzpirat/guard-rspectacle.png)](http://travis-ci.org/netzpirat/guard-rspectacle)

Guard::RSpectacle automatically tests your application with [RSpec]() when files are modified.

Tested on MRI Ruby 1.8.7, 1.9.2, 1.9.3, REE and the latest versions of JRuby & Rubinius.

If you have any questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

## Prove of concept

**This is an early stage proof of concept. The idea is that Guard starts the Rails environment, reloads changed Ruby files and starts the RSpec runner embedded in the current process.**

## Install

### Guard and Guard::RSpectacle

Please be sure to have [Guard](https://github.com/guard/guard) installed.

Add it to your `Gemfile`, preferably inside the development group:

    gem 'guard-rspectacle', :git => 'git://github.com/netzpirat/guard-rspectacle.git'

Add guard definition to your `Guardfile` by running this command:

    $ guard init rspectacle

## Usage

Please read the [Guard usage documentation](https://github.com/guard/guard#readme) for information about Guard.

## Guardfile

Guard::RSpectacle can be adapted to all kind of projects. Please read the
[Guard documentation](https://github.com/guard/guard#readme) for more information about the Guardfile DSL.

```ruby
guard :rspectacle do
  watch('spec/spec_helper.rb')                        { %w(spec/spec_helper spec) }
  watch('config/routes.rb')                           { %w(config/routes.rb spec/routing) }
  watch('app/controllers/application_controller.rb')  { 'spec/controllers' }

  watch(%r{^spec/.+_spec\.rb$})

  watch(%r{^app/(.+)\.rb$})                           { |m| ["app/#{m[1]}.rb", "spec/#{m[1]}_spec.rb"] }
  watch(%r{^lib/(.+)\.rb$})                           { |m| ["lib/#{m[1]}.rb", "spec/lib/#{m[1]}_spec.rb"] }
  watch(%r{^app/controllers/(.+)_controller\.rb$})    { |m| [
    "app/controllers/#{m[1]}_controller.rb",
    "spec/controllers/#{m[1]}_spec.rb",
    "spec/routing/#{m[1]}_routing_spec.rb",
    "spec/acceptance/#{m[1]}_spec.rb"
  ]}
end
```

**NOTE: When using `watch` with a block, you must return all files that should be reloaded.**

## Options

There are many options that can customize Guard::Jasmine to your needs. Options are simply supplied as hash when
defining the Guard in your `Guardfile`:

```ruby
guard :rspectacle, :cli => '--format Fuubar --backtrace --tag @focus', :all_on_start => false do
  ...
end
```

### General options

The general options configures the environment that is needed to run Guard::RSpectacular and RSpec:

```ruby
:cli => '--tag @focus'         # RSpec CLI options
                               # default: ''
```

### Spec runner options

The spec runner options configures the behavior driven development (or BDD) cycle:

```ruby
:all_on_start => false         # Run all specs on start.
                               # default: true

:keep_failed => false          # Keep failed examples and add them to the next run again.
                               # default: true

:keep_pending => false         # Keep pending examples and add them to the next run again.
                               # default: true

:all_after_pass => false       # Run all specs after all examples have passed again after failing.
                               # default: true
```

### System notifications options

These options affects what system notifications (growl, libnotify or notifu) are shown after a spec run:

```ruby
:notifications => false        # Show success and error notifications.
                               # default: true

:hide_success => true          # Disable successful spec run notification.
                               # default: false
```

## Important note on reloading

The ability to run specs immediately comes at a cost:

1. In your `Guardfile`, you have to specify which files should be reloaded (apart from specs to be executed).  But don't
   worry, the default template takes care of it.
2. When a file is changed, it is reloaded the Ruby code with
   [Kernel#load](http://ruby-doc.org/core-1.9.3/Kernel.html#method-i-load), which only re-interprets the file.

This, for example, means that a method already defined on a class (including `initialize`) will not be removed
simply by deleting that method from the source code:

```ruby
class Dinner
  def initialize
    raise "Too early"
  end
end
```

The spec that uses this class will fail for the obvious reason. So your first thought may be to just remove `initialize`
method. But that will not work and you should rewrite the class above:

```ruby
class Dinner
  def initialize
    super
  end
end
```

When you are done testing, restart `guard` to load the file afresh. Unfortunately this inconvenience can't be fixed
easily (suggest if you know how?). So just keep in mind: **you are monkey-patching within a single `guard` session**.

## Alternatives

Please have a look at the rock solid [guard-rspec](https://github.com/guard/guard-rspec). Guard::Rspectacular uses it
for continuous testing.

## Issues

You can report issues and feature requests to [GitHub Issues](https://github.com/netzpirat/guard-rspectacle/issues).
Try to figure out where the issue belongs to: Is it an issue with Guard itself or with Guard::RSpectacle? Please don't
ask question in the issue tracker, instead join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

When you file an issue, please try to follow to these simple rules if applicable:

* Make sure you run Guard with `bundle exec` first.
* Add debug information to the issue by running Guard with the `--verbose` option.
* Add your `Guardfile` and `Gemfile` to the issue.
* Make sure that the issue is reproducible with your description.

## Development

- Documentation hosted at [RubyDoc](http://rubydoc.info/github/guard/guard-rspectacle/master/frames).
- Source hosted at [GitHub](https://github.com/netzpirat/guard-rspectacle).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested.
* Update the [Yard](http://yardoc.org/) documentation.
* Update the README.
* Update the CHANGELOG for noteworthy changes.
* Please **do not change** the version number.

For questions please join us in our [Google group](http://groups.google.com/group/guard-dev) or on
`#guard` (irc.freenode.net).

## Contributors

* [Dmytrii Nagirniak](https://github.com/dnagir)
* [Felipe Kaufmann](https://github.com/effkay)

## Acknowledgment

- [David Chelimsky](https://github.com/dchelimsky) for [RSpec](https://github.com/rspec) to write elegant tests with
  passion.
- All the authors of the numerous [Guards](https://github.com/guard) available for making the Guard ecosystem so much
  growing and comprehensive.

## License

(The MIT License)

Copyright (c) 2011 - 2012 Michael Kessler

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

