Rails.application.routes.draw do
  match 'javascripts/*path.js', :to => 'barista#show'
end