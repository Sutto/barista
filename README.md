# Barista

Barista is very, very similar to [bistro\_car](http://github.com/jnicklas/bistro_car) (infact, credit where credit is due - it shares similar
code / is almost a fork).

The main difference being, it lets you use coffee as you would javascript. Simply put, Write coffee
and place it in `app/coffeescripts` and Barista will automatically serve it as if it was placed in `public/javascripts`

That is, `app/coffeescripts/demo.coffee` will work for `/javascripts/demo.js`. Even better (and more importantly
for me), it provides `Barista.compile_all!` which takes all coffee files and compiles them into `public/javascripts`.

If you're using Jammit, this means you can simple run a rake task (`rake barista:brew` before running jammit) and
your coffeescripts will be automatically provided, ready for bundling.

To add to your project, simply add:

    gem 'barista', '>= 0.1.2'
    
To your Gemfile and run bundle install.

As you place .coffee files in app/scripts, it will automatically handle them for you.

Please note that for Jammit compatibility etc, by default in test and dev mode it will
automatically compile all coffeescripts that have changed before rendering the page.

Barista require rails 3+ (but patches for Rails 2 will be accepted.)

## Configuration ##

Please note that barista lets you configure several options. To do this,
it's as simple as setting up an initializer with:

    rails generate barista_install
    
Then editing `config/initializers/barista_config.rb`.

Currently available options are:

* root - the folder path to read coffeescripts from, defaults to app/coffeescripts
* output\_root - the folder to write them into, defautls to public/javascripts.
* no\_wrap - stop coffee from automatically wrapping JS in a closure.

