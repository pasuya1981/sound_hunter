module MixModule

  class Mixset
    attr_reader :name

    def initialize(name)
      @name = name
    end
  end
end

include MixModule
set = Mixset.new('Michael Jackson')
p set.name



