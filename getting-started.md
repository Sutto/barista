# Getting Started

Out of the box, Barista has semi-automatic support for Rails 3.0, Rails 2 (currently untested) and Sinatra. With a minimal amount of effort, you can also make it work in any Rack-based framework.

## Rails 3

Adding Barista to your Rails 3 application should as simple as adding two gems to your `Gemfile`, and running  two commands. To get started, open up your `Gemfile` and add the following:

    gem "json" # Only needed if on Ruby 1.8 / a platform that ships without JSON
    gem "barista"

Next, you'll need to run the the following:

    bundle install
    rails g barista:install

This will install the gem into your application and will generate a file in `config/initializers/barista_config.rb` that contains a set of options to configure Barista options.

## Rails 2

Much like on Rails 3, Barista supports deep integration into Rails 2. The only thing missing (that is currently supported in the Rails 3 version) is built in support for generating a config file. If you're using bundler in your application, all you need to do is add:

    gem "json" # Only needed if on Ruby 1.8 / a platform that ships without JSON
    gem "barista"
    
To your `Gemfile`. If you're not using bundler, doing `gem install json barista` and requiring barista both in your application should be enough to get you started.

If you wish to change the barista configuration, take a look at the  [Rails 3 initializer](https://github.com/Sutto/barista/blob/master/lib/generators/barista/install/templates/initializer.rb) and modify it to suite your application as needed.

## Sinatra

Adding Barista to a Sinatra application is a relatively straight forward affair. Like in Rails 2 and Rails 3, you first need to add and require the barista gem and (optionally, the json gem). Unlike Rails 2 and 3 (which set it up automatically), you must also register the extension in your application. So, in the scope of your app (either the top level scope or the `Sinatra::Application` subclass you're using), you then need to simple add:

    register Barista::Integration::Sinatra

Which will automatically set up the Barista environment and other similar details (e.g. the automatic compilation filter). Since you don't have initializers like you do in Rails, you
can then simply run your `Barista.configure` call and block anywhere before your application starts serving requests.

## Other Rack-based Frameworks

Lastly, even though it is built out of the box to support Rails and Sinatra, Barista can also be used with any Rack-based framework. For proper integration, several things must be done. Namely, wherever you declare your middleware (e.g. in a `config.ru` file), you should register the two pieces of middleware barista uses. `Barista::Filter` should only be registered when
Barista performs compilation (e.g. in development mode) and `Barista::Server::Proxy` should be registered if you want it to support automatic serving of a `coffeescript.js` file and / or
on the fly (versus pre-request compilation) of CoffeeScripts.

For example, your `config.ru` may look like:

    # Setup goes here...
    use Barista::Filter if Barista.add_filter?
    use Barista::Server::Proxy
    run MyRackApplication
    
Next, you need to configure barista anywhere before your the above code is run. e.g by adding the following immediatly preceeding it:

    # Barista (for CoffeeScript Support)
    Barista.app_root = root
    Barista.root     = File.join(root, 'coffeescripts')
    Barista.setup_defaults
    barista_config = root + '/barista_config.rb'
    require barista_config if File.exist?(barista_config)
    
Hence, if you'e using, for example, [serve](https://github.com/jlong/serve) users should have a `config.ru` that looks similar to [this example](https://github.com/YouthTree/site-design/blob/master/config.ru).