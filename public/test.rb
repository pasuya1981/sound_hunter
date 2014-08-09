def what(type)
  sym = :fuck if type == '111'
  sym = :you if type == '222'
  sym
end

sym = what '111'
p sym