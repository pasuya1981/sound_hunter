

class Object
  def present?
  	p "Before: #{self.inspect}"
    self.to_s.strip!.to_s.size > 0
    p "After: #{self.inspect}"
  end
end

hash = { :name => 'what' }
d