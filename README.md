# Barista #

Barista is a set of tools to make using [CoffeeScript](http://jashkenas.github.com/coffee-script/) in Rails 3, Rails 2 and Rack applications
easier. You can think of it as similar to [Compass]() but instead of for Sass, it's for CoffeeScript.

Getting started is fairly simple - The short version for Rails 3 is simply:

1. Add `gem 'barista', '~> 1.0'` to your Gemfile
2. Run `bundle install`
3. Run `rails generate barista:install`

Place your CoffeeScript's in `app/coffeescripts` and Barista will automatically compile them on change into `public/javascripts`.


As an added bonus, Barista also gives:

* Automatic support for a `:coffeescript` filter in Haml (when Haml is loaded before barista) - Automatically converting inline CoffeeScript
  to JavaScript for you.
* Where possible, support for `coffeescript_include_tag` and `coffeescript_tag`.
* When possible, instead of pre-compiling in development and test modes, Barista will embed CoffeeScript in the page for you.
* Support for Heroku via `therubyracer` and either pre-compiled JS or, optionally, a lightweight Rack app that generates on request.


## General Information

Barista transparently compiles CoffeeScript to JavaScript - When a `.coffee` file is changed and the page is refreshed, it first regenerates all `.js` files whose `.coffee` sources have been recently changed. This way, you can refresh immediately after saving the `.coffee` file, and not worry about an old `.js` file being sent to the browser (as often happens when using `coffee --watch`).

Barista supports using `therubyracer` when installed or, by default, using either the `node` executable or `jsc` (on OSX) to compile your scripts. There is
no need for you to install the coffee script executable in node - having Node itself or any of the alternatives available is enough for you to get support.

When you want to deploy, you can simple run `rake barista:brew` to force the compilation of all JavaScripts fro the current application.

## In Practice

Barista not only supports compiling all JavaScripts on demand (via `rake barista:brew` as above, or `Barista.compile_all!`) but it
also ships with a simple Rack server app that will compile on demand for platforms such as Heroku, meaning you don't need write access
(although it is helpful).

If you're using Jammit, the precompilation phase (e.g. `rake barista:brew` before running jammit) will make it possible for your application
to automatically bundle not only normal JavaScripts but also your CoffeeScripts.

To add to your project, simply add:

    gem 'barista', '~> 1.0'
    
To your Gemfile and run bundle install.

Please note that for Jammit compatibility, in test and dev mode (by default) it will
automatically compile all CoffeeScripts that have changed before rendering the page.

Barista works out of the box with Rails 3 (and theoretically, Rails 2) - with support for Rack if
you're willing to set it up manually. More docs on how to set it up for other platforms
will be posted in the near future.

## Configuration ##

Please note that barista lets you configure several options. To do this,
it's as simple as setting up an initializer with:

    rails generate barista:install
    
Then editing `config/initializers/barista_config.rb`. The options available are:

### Boolean Options

All of these come in the form of `#option?` (to check it's status), `#option=(value)` (to set it)
and `#option!` (to set the value to true):

* `verbose` - Output debugging error messages. (Defaults to true in test / dev)
* `bare` - Don't wrap the compiled JS in a Closure
* `add_filter` - Automatically add an around filter for processing changes. (Defaults to true in test / dev)
* `add_preamble` - Add a time + path preamble to compiled JS. (Defaults to true in test / dev)
* `exception_on_error` - Raise an exception on compilation errors (defaults to true)
* `embedded_interpreter` - Embeds coffeescript + link to coffee file instead of compiling for include tags and haml filters. (Defaults to true in test / dev)

### Path options

* `root` - the folder path to read coffeescripts from, defaults to app/coffeescripts
* `output_root` - the folder to write them into, defaults to public/javascripts.
* `change_output_prefix!` - method to change the output prefix for a framework.
* `verbose` - whether or not barista will add a preamble to files.
* `js_path` - Path to the pure-javascript compiler.
* `env` - The application environment. (defaults to Rails.env)
* `app_root` - The root of the application.
* `bin_path` - The path to the `node` executable if non-standard and not using therubyracer.
* All of the hook methods mentioned below.

## Frameworks ##

One of the other main features Barista adds (over other tools) is frameworks similar
to Compass. The idea being, you add coffee scripts at runtime from gems etc. To do this,
in your gem just have a `coffeescript` directory and then in you gem add the following code:

    Barista::Framework.register 'name', 'full-path-to-directory' if defined?(Barista::Framework)
    
For an example of this in practice, check out [bhm-google-maps](http://github.com/YouthTree/bhm-google-maps)
or, the currently-in-development, [shuriken](http://github.com/Sutto/shuriken). The biggest advantage of this
is you can then manage js dependencies using existing tools like bundler.

In your `Barista.configure` block, you can also configure on a per-application basis the output directory
for individual frameworks (e.g. put shuriken into vendor/shuriken, bhm-google-maps into vendor/bhm-google-maps):

    Barista.configure do |c|
      c.change_output_prefix! 'shuriken',        'vendor/shuriken'
      c.change_output_prefix! 'bhm-google-maps', 'vendor/bhm-google-maps'
    end
    
Alternatively, to prefix all, you can use `Barista.each_framework` (if you pass true, it includes the 'default' framework
which is your application root).

    Barista.configure do |c|
      c.each_framework do |framework|
        c.change_output_prefix! framework.name, "vendor/#{framework.name}"
      end
    end
    
## Hooks ##

Barista lets you hook into the compilation at several stages. Namely:

* before compilation
* after compilation
* after compilation fails
* after compilation complete

To hook into these hooks, you can use like so:

* `Barista.before_compilation { |path| puts "Barista: Compiling #{path}" }`
* `Barista.on_compilation { |path| puts "Barista: Successfully compiled #{path}" }`
* `Barista.on_compilation_with_warning { |path, output| puts "Barista: Compilation of #{path} had a warning:\n#{output}" }`
* `Barista.on_compilation_error { |path, output| puts "Barista: Compilation of #{path} failed with:\n#{output}" }`
* `Barista.on_compilation_complete { puts "Barista: Successfully compiled all files" }`

These allow you to do things such as notify on compilation, automatically
perform compression post compilation and a variety of other cool things.

An excellent example of these hooks in use is [barista\_growl](http://github.com/TrevorBurnham/barista_growl),
by Trevor Burnham - a gem perfect for development purposes that automatically shows growl messages
on compilation.

# Contributors / Credits

The following people have all contributed to Barista:

* [Xavier Shay](https://github.com/xaviershay) - Added preamble text to generated text in verbose mode.
* [einarmagnus](https://github.com/einarmagnus) - Fixed jruby support.
* [Matt Dean](https://github.com/trabian) - Added `before_full_compilation` and `on_compilation_complete` hooks.
* [Trevor Burnham](https://github.com/TrevorBurnham) - Misc. documentation tweaks and hooks idea.
* [Sean McCullough](https://github.com/mcculloughsean) - Initial switch to support bare (vs. no\_wrap)
* [Ben Atkin](https://github.com/benatkin) - Docs work.
* [Ben Hoskings](https://github.com/benhoskings) Misc fixes, added preamble support.

Barista was originally heavily inspired by [Bistro Car](https://github.com/jnicklas/bistro_car), but has taken a few fundamentally
different approach in a few areas.

Barista builds upon the awesome [coffee-script](https://github.com/josh/ruby-coffee-script) gem.

It's all possible thanks to [CoffeeScript](https://github.com/jashkenas/coffee-script) by Jeremy Ashkenas.

## Note on Patches/Pull Requests ##
 
1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright ##

Copyright (c) 2010 Darcy Laycock. See LICENSE for details.
