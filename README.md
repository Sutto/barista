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

    gem 'barista', '>= 0.2.1'
    
To your Gemfile and run bundle install.

As you place .coffee files in app/scripts, it will automatically handle them for you.

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

    Barista.configure do |config|
      config.change_output_prefix! 'shuriken',        'vendor/shuriken'
      config.change_output_prefix! 'bhm-google-maps', 'vendor/bhm-google-maps'
    end
    
Alternatively, to prefix all, you can use `Barista.each_framework` (if you pass true, it includes the 'default' framework
which is your application root).

    Barista.configure do |config|
      config.each_framework do |framework|
        config.change_output_prefix! framework.name, "vendor/#{framework.name}"
      end
    end

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

