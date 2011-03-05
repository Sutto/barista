namespace :barista do

  desc "Compiles coffeescripts from app/coffeescripts into public/javascripts"
  task :brew => :environment do
    if !Barista::Compiler.available?
      if Barista::Compiler.bin_path.nil?
        $stderr.puts "Looks like Coffescript is not installed."
      else
        $stderr.puts "'#{Barista::Compiler.bin_path}' was unavailable."
      end
      exit 1
    end
    Barista.compile_all! true, false
  end

end
