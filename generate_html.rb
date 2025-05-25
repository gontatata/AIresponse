# generate_html.rb
File.open("index.html", "w") do |file|
  file.puts "<!DOCTYPE html>"
  file.puts "<html>"
  file.puts "<head><title>公開テスト</title></head>"
  file.puts "<body><h1>これはRubyで生成したページです</h1></body>"
  file.puts "</html>"
end
