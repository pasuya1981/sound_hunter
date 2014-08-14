// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function(){
  /* Search form input control */
  $("input.btn-search-submit").addClass('disabled');
  $(".search_input").change(function() {
    if($(this).val() < 1) {
      $("input.btn-search-submit").addClass('disabled');
    } else {
      $("input.btn-search-submit").removeClass('disabled');
    }
  });
});

/* Update URL when doing Ajax request */
if (history && history.pushState){
  $(function(){
   $('body').on('click', 'a', function(e){
      $.getScript(this.href);
      history.pushState(null, '', this.href);
    });
    $(window).bind("popstate", function(){
      $.getScript(location.href);
    });
  });
}

/* Set up sound-manager */
soundManager.setup({
  url: './',
  flashVersion: 9,

  preferFlash: false, // prefer 100% HTML5 mode, where both supported
  onready: function() {
    // console.log('SM2 ready!');
  },
  ontimeout: function() {
    // console.log('SM2 init failed!');
  },
  defaultOptions: {
    // set global default volume for all sound objects
    volume: 100,
  }
});
