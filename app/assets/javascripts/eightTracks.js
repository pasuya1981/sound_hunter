(function ( $ ) {
 
  // This works on DOM.
  $.fn.greenify = function() {
    this.css( "color", "green" );
    return this;
  };

  // Public Methods
  $.addCollection = function( mixID ) {
  	alert("Adding Collection for Mix: " + mixID)
  };

  $.rtrim = function( str ) {
    return str.replace( /\s+$/, "" );
  };
}( jQuery ));