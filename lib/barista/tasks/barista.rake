require 'barista/rake_task'

Barista::RakeTask.new do |t|
  t.namespace = :barista
  t.task_name = :brew
  t.rails     = true
end
