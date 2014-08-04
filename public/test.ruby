def t1
  if true
  	puts 'return point'
  	return
  end
end

def t2
  t1
  puts 'hi'
end

t2
