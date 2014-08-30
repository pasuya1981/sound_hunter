def humanize secs
  [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
    if secs > 0
      secs, n = secs.divmod(count)
      puts "The secs: #{secs}"
      puts "The n is: #{n}"
      "#{n.to_i} #{name}"
    end
  }.compact.reverse.join(' ')
end

puts humanize 120