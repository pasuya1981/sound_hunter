module MixModule

  class MixSet
    attr_accessor :info
    def initialize()
      @info = {}
    end
  end

  class Mix
    attr_accessor :info
    def initialize(*infos)
      @info = infos[0] if infos[0].kind_of?(Hash)
      @info = {} unless @info
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