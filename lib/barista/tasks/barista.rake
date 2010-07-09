namespace :barista do

  desc "Compiles coffeescripts from app/coffeescripts into public/javascripts"
  task :brew => :environment do
    if !Barista::Compiler.available?
      $stderr.puts "'#{Barista::Compiler.bin_path}' was unavailable."
      exit 1
    end
    Barista.compile_all! true, false
  end

end
