taggin_count = 20000
h_size = taggin_count > 50000 ? 3 : taggin_count > 10000 ? 4 : 5
puts h_size

puts "72,000+".gsub(/\+/i, '').gsub(/,/,'')

puts "72,000+".to_i

