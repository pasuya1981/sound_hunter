





def search_method_for(obj, keyword)
  array = []
  regexp = Regexp.new keyword, true #
  puts regexp
  obj.methods.map { |m| array << m if m.to_s =~ regexp}
  puts array
end

search_method_for 'asdf', 'gSUb'