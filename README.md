# Barista #

Barista is very, very similar to [bistro\_car](http://github.com/jnicklas/bistro_car) (infact, credit where credit is due - it shares similar
code / is almost a fork).

The main difference being, it lets you use coffee as you would javascript. Simply put, Write coffee
and place it in `app/coffeescripts` and Barista will automatically serve it as if it was placed in `public/javascripts`

That is, `app/coffeescripts/demo.coffee` will work for `/javascripts/demo.js`. Even better (and more importantly
for me), it provides `Barista.compile_all!` which takes all coffee files and compiles them into `public/javascripts`.

If you're using Jammit, this means you can simple run a rake task (`rake barista:brew` before running jammit) and
your coffeescripts will be automatically provided, ready for bundling.

To add to your project, simply add:

    gem 'barista', '>= 0.5.0'
    
To your Gemfile and run bundle install.

As you place .coffee files in app/coffeescripts, it will automatically handle them for you.

Please note that for Jammit compatibility etc, by default in test and dev mode it will
automatically compile all coffeescripts that have changed before rendering the page.

Barista require rails 3+ (but patches for Rails 2 will be accepted.)

## Frameworks ##

One of the other main features Barista adds (over bistro\_car) is frameworks similar
to Compass. The idea being, you add coffeescripts at runtime from gems etc. To do this,
in your gem just have a coffeescript directory and then in you gem add the following code:

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

## Configuration ##

Please note that barista lets you configure several options. To do this,
it's as simple as setting up an initializer with:

    rails generate barista_install
    
Then editing `config/initializers/barista_config.rb`.

Currently available options are:

* root - the folder path to read coffeescripts from, defaults to app/coffeescripts
* output\_root - the folder to write them into, defautls to public/javascripts.
* no\_wrap - stop coffee from automatically wrapping JS in a closure.
* change\_output\_prefix! - method to change the output prefix for a framework.

## Note on Patches/Pull Requests ##
 
1. Fork the project.
2. Make your feature addition or bug fix.
3. Add tests for it. This is important so I don't break it in a future version unintentionally.
4. Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
5. Send me a pull request. Bonus points for topic branches.

## Copyright ##

Copyright (c) 2010 Darcy Laycock. See LICENSE for details.