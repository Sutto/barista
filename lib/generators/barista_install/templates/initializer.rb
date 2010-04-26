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
  
end