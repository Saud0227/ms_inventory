task :dev do
  port = 9292
  puts "Launching rerun on port 9292"
  puts "  http://localhost:9292"
  system('rerun rackup --force-polling  --ignore "*.{erb,slim,js,css}"')
end

task :kill_running do
  puts "Check port empty"
  if system("lsof -i:9292", out: '/dev/null')
    puts "Port busy, killing process"
    system('lsof -t -i:9292 | xargs kill -9')
  end
  print "Port cleared\n"
end