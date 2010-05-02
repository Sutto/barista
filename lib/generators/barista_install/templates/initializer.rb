# Configure barista.
Barista.configure do |c|
  
  # Change the root to use app/scripts
  # c.root = Rails.root.join("app", "scripts")
  
  # Change the output root, causing Barista to compile into public/coffeescripts
  # c.output_root = Rails.root.join("public", "coffeescripts")
  
  # Disable wrapping in a closure:
  # c.no_wrap = true
  # ... or ...
  # c.no_wrap!
  
  # Change the output root for a framework:
  
  # config.change_output_prefix! 'framework-name', 'output-prefix'
  
  # or for all frameworks...
  
  # config.each_framework do |framework|
  #   config.change_output_prefix! framework.name, "vendor/#{framework.name}"
  # end
  
  # or, prefix the path for the app files:
  
  # config.change_output_prefix! :default, 'my-app-name'
  
end