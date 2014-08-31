module ApplicationHelper

  include SessionHelper
  def humanize secs # Source: http://stackoverflow.com/questions/4136248/how-to-generate-a-human-readable-time-range-using-ruby-on-rails
    [[60, '秒'], [60, '分'], [24, '時'], [1000, '日']].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse.join(' ')
  end

  def bootstrap_class_for flash_type
# Bootstrap 3.0 alert CSS syntaxs
# <div class="alert alert-success" role="alert">...</div>
# <div class="alert alert-info" role="alert">...</div>
# <div class="alert alert-warning" role="alert">...</div>
# <div class="alert alert-danger" role="alert">...</div>
  	style = { success: 'alert-success', 
              info:    'alert-info', 
              warning: 'alert-warning', 
              danger:  'alert-danger' }[flash_type.to_sym] || 'alert-info'
  end

  

  def dynamic_action_name
    action_name = controller.action_name
    return 'create' if action_name =~ /new/i
    return 'create_eight_tracks_account' if action_name =~ /signup/i
  end

  

  # Bootstrap 3.0 style label
  def random_label_for(tag_hash)
    name = tag_hash[:tag_name]
    if name.nil?
      name = tag_hash['tag_name']
      taggin_count = parse_tag_count_to_int(tag_hash['taggin_count'])
    else
      taggin_count = parse_tag_count_to_int(tag_hash[:taggin_count])
    end
    h_size = map_count_to_size taggin_count
    rand_style = [ 'success', 'info', 'warning', 'danger'][rand(0..3)] #'Primary' & 'Defaut' are removed, can't see in white background
    inner_content = content_tag('span', link_to(tag_translate(name), hot_tags_search_path(keyword: name), remote: true), class: "label label-#{rand_style}")  
    content_tag("h#{h_size}", inner_content, class: "display-in-line tags")
  end

  #content_tag(:a, tag_translate(name), href: hot_tags_search_path(keyword: name))

  def tag_translate(name)
    name_in_sym = name.downcase.to_sym
    { :"hip hop" => "嘻哈", 
      :"alternative rock" => "另類搖滾",
      :fun => "好玩",
      :electronic => "電音",
      :punk => "龐客",
      :instrumental => "樂器",
      :"indie rock" => "印度搖滾",
      :mashup => "混搭",
      :acoustic => "原聲",
      :love => "愛情",
      :christmas => "聖誕",
      :country => "鄉村",
      :happy => "快樂",
      :weed => "雜草",
      :chill => "冷靜",
      :classical => "古典",
      :soundtrack => "配樂",
      :jazz => "爵士",
      :piano => "鋼琴",
      :sex => "性感",
      :party => "派對",
      :relax => "放輕鬆",
      :workout => "健身",
      :"90s" => "八零年代",
      :morning => "早晨",
      :study => "學習" }[name_in_sym] || name
  end

  private
    def parse_tag_count_to_int(tag_string)
      tag_string.gsub(/\+/i, '').gsub(/,/,'').to_i
    end

    def map_count_to_size(taggin_count)
      h_size =  taggin_count > 50000 ? 3 : taggin_count > 10000 ? 4 : 5
    end
end
