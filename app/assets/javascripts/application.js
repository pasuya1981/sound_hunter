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

$(document).ready(function() {

  if($(".search_input").val().length < 1){
  	$(".btn-search-submit").addClass('disabled');
  }

  $(".search_input").keyup(function(){
  	/* Act on the event */
  	if($(this).val().length < 1) {
  	  $(".btn-search-submit").addClass('disabled');
  	} else  {
  	  $(".btn-search-submit").removeClass('disabled');
  	}
  });

  $(".search_input").mouseleave(function(){
    /* Act on the event */
    if($(this).val().length < 1) {
      $(".btn-search-submit").addClass('disabled');
    } else  {
      $(".btn-search-submit").removeClass('disabled');
    }
  });
});



//  $(document).ready(function() {
//    $("div.hidden-content").hide();
//    $("img.visible").show();
//    $("img.visible").hover(function() {
//    	// body...
//    	$(this).hide();
//    	$(this).parent().find('div.hidden-content').show();
//    });  
//    $("div.hidden-content").mouseleave(function() {
//    	$(this).hide();
//    	$(this).parent().find('img.visible').show();
//    });  
//    $("div.hidden-content").mouseout(function() {
//    	$(this).hide();
//    	$(this).parent().find('img.visible').show();
//    });

//  $(document).scroll(function(event) {
//  	/* Act on the event */
//  	if ($(window).scrollTop() + $(window).height() == $(document).height()) {
//  	  $('html, body').animate({scrollTop:0},600);
//  	  //alert($(window).height());
//  	};
//  });
//});



