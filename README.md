# Guard::RSpectacle [![Build Status](https://secure.travis-ci.org/netzpirat/guard-rspectacle.png)](http://travis-ci.org/netzpirat/guard-rspectacle)

Guard::RSpectacle automatically tests your application when files are modified.

Tested on MRI Ruby 1.8.7, 1.9.2, REE and the latest versions of JRuby & Rubinius.

If you have any questions please join us on our [Google group](http://groups.google.com/group/guard-dev) or on `#guard`
(irc.freenode.net).

## Prove of concept

**This is an early stage prove of concept. The idea is that Guard starts the Rails environment, reloads changed Ruby files and starts the RSpec runner embedded in the current process.**

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
guard :rspectacle, :cli => '--format Fuubar --backtrace --tag @focus', :all_on_start => false do
  ...
end
```

### Options

You can configure `guard-rspectacle` with the following options:

```ruby
:cli => '--tag @focus'                        # RSpec CLI options
                                              # default: ''

:notifications => false                       # Show success and error notifications.
                                              # default: true

:hide_success => true                         # Disable successful spec run notification.
                                              # default: false

:all_on_start => false                        # Run all specs on start.
                                              # default: true

:keep_failed => false                         # Keep failed specs and add them to the next run again.
                                              # default: true

:all_after_pass => false                      # Run all specs after a suite has passed again after failing.
                                              # default: true
```

## Important note on reloading

The ability to run specs immediately comes at a cost:

1. in your `Guardfile`, you have to specify which files should be reloaded (apart from specs to be executed).  But don't worry, the default template takes care of it.
2. When a file is changed, it is reloaded using Ruby `reload` method which only re-interprets the file.


This, for example, means that a method already defined on a class (including `initialize`) will not be removed
simply by deleting that method from source code:

```ruby
class Dinner
  def initialize; raise "Too early"; end
end
```

The spec that uses this class will fail for the obvious reason.
So your first thought may be to just remove `initialize` method.

But that will not work and you should rewrite the class above:

```ruby
class Dinner
  def initialize; super; end
end
```

When you are done testing, restart `guard` to load the file afresh.

Unfortunately this inconvenience can't be fixed easily (suggest if you know how?).

So just keep in mind: **you are monkey-patching within a single `guard` session**.

## License

(The MIT License)

Copyright (c) 2011 Michael Kessler

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

