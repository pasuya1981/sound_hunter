module MixModule

  class MixSet
    attr_accessor :info
    def initialize()
      @info = {}
    end
  end

  class Mix
    attr_accessor :info
    def initialize
      @info={}
      yield(self) if block_given?
    end 
  end

  class TracksUser
    attr_accessor :info
    def initialize
      @info = {}
      yield(self) if block_given?
    end
  end
end