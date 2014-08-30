
the_hash = {:preview=>{:id=>"624851", :login=>"serenawhitney", :path=>"/users/624851", :web_path=>"/serenawhitney", :avatar_urls=>"http://8tracks.imgix.net/avatars/000/624/851/52945.original.jpg"}}, :liked_by_current_user=>"false", :likes_count=>"170", :certification=>"gold", :duration=>"4214", :tracks_count=>"14", :id=>"980884", :path=>"/mixes/980884", :web_path=>"/serenawhitney/underrated-mj-songs-and-remixes", :name=>"Underrated MJ songs and remixes", :user_id=>"624851", :published=>"true", :cover_urls=>"http://8tracks.imgix.net/i/001/003/408/88567.original-6756.png?fm=jpg&q=65&w=250&h=250&fit=crop", :description=>"Eleven tracks including music by Michael Jackson and Oddissee.", :plays_count=>"4511", :tag_list_cache=>"michael jackson, soul / r&b, king of pop, r&b", :first_published_at=>"2012-08-29T16:28:44Z", :first_published_at_timestamp=>"1346257724"}

require 'json'
puts JSON.pretty_generate the_hash
