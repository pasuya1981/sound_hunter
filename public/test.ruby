#def method1
#  yield('1', '2')
#  return
#  puts 'still got here'
#end#

#def method2
#  out_value = 'out value'
#  method1 {|a,b| puts "#{a} and #{b} and out value is #{out_value}" }
#end#

#method2

def test
  return hellow = 'hellow' + ' good afternoon' if true
end

def test2
  puts test
end


Object.methods.each do |m|
  puts m if m.to_s =~ /is/i
end



