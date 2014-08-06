module MixModule

  class MixSet
    attr_reader :name, :tags_list, :mixes, :smart_type, :sort, :desc, :pagination  

    def initialize(params={})
      raise ArgumentError unless params[:name] && params[:pagination]
      @name = params[:name]
      @pagination = params[:pagination]
      @tags_list = params[:tags_list] if params[:tags_list]
      @mixes = params[:mixes] if params[:mixes]
      @smart_type = params[:smart_type] if params[:smart_type]
      @sort = params[:sort] if params[:sort]
      @desc = params[:desc] if params[:desc]
    end
  end
end