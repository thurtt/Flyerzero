// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

navigator.geolocation.getCurrentPosition(foundLocation, noLocation);

$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');

	$('.slideshow').cycle({
		fx: 'shuffle',
		timeout: 3000,
		speedIn:  500
	});

	$('#add_link').click( function(){
		$('#kickstarter').fadeOut(function(){$('#submit').fadeIn();});
		$('#flyer').fadeOut(function(){$('#dragdrop').fadeIn();});
		//$('#add_panel').toggle('blind');
	});

	$('#add_panel input#event_expiry').datepicker({ dateFormat: 'D, dd M yy' });


	$('#add_panel input#cancel').click( function(){
		$('#submit').fadeOut(function(){$('#kickstarter').fadeIn();});
		$('#dragdrop').fadeOut(function(){$('#flyer').fadeIn();});
	});
});

function loadFlyerData(lat, lng) {
	$.get('flyers/?lat=' + lat + '&lng=' + lng ,function(data) {
		$('#content').html(data);
	});
}

function foundLocation(position) {
  var lat = position.coords.latitude;
  var long = position.coords.longitude;
  loadFlyerData(lat, long);
  //alert('Found location: ' + lat + ', ' + long);
}

function noLocation() {
  loadFlyerData(null,null);
  //alert('Could not find location');
}
