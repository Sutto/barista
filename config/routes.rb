Rails.application.routes.draw do
  match 'javascripts/*js_path.js', :to => 'barista#show'
end