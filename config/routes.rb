Rails.application.routes.draw do
  barista_server = Barista::Server.new
  match 'javascripts/*js.js',       :to => barista_server
  match 'coffeescripts/*js.coffee', :to => barista_server
end