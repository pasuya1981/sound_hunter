(function ( $ ) {
 
  // This apply to DOM
  $.fn.greenify = function() {
      this.css( "color", "green" );
      return this;
  };

  $.addMixToCollection = function (mixID, collectionID) {
  	console.log("You are calling function from Zack's plugins");
  	console.log("The mix id: " + mixID);
  	console.log("The collection id: " + collectionID);
  }

  // Static method
  $.ltrim = function( str ) {
      return str.replace( /^\s+/, "" );
  };
  $.rtrim = function( str ) {
      return str.replace( /\s+$/, "" );
  };

}( jQuery ));