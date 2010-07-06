namespace :barista do

  desc "Compiles coffeescripts from app/scripts into public/javascripts"
  task :brew => :environment do
    Barista.compile_all!(true)
  end

end
