// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
// require webshims/minified/extras/modernizr-custom
// require webshims/minified/polyfiller
// require history_jquery

var latitude;
var longitude;
var user_latitude;
var user_longitude;
var user_country = 'US';
var query_flyers = true;


$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');
	
	
	$('#new_location').blur( function(){
		$('#change_location').fadeOut('fast', function() {
			$('#address').fadeIn("fast", function(){});
		});
	});

	$('input#new_location').keypress( function(event){
		var keycode = (event.keyCode ? event.keyCode : event.which);
		if(keycode == '13'){
			if ( $('input#new_location').val() != '' ){
				changeLocation( $('input#new_location').val() );
			}
		}
	});
	registerEvents();
	getUserLocation();
	initSubmitForm();

});

// disable the default drag and drop behavior
$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

function registerEvents(){
	$('#login').unbind();
	$('#login').click(function(){
			facebook_login(function(){
				location.href="/";
			});
	});
	
	$('#logout').unbind();
	$('#logout').click(function(){
			facebook_logout();
	});
        
        $('#address').unbind();
	$('#address').click( function(){
		$('#address').fadeOut("fast", function() {
			$('#change_location').fadeIn("fast", function() {
				$('#new_location').focus();
			});
		});
	});

	
	$('button.change_location').unbind();
	$('button.change_location').click( function(){
		if ( $('input#new_location').val() != '' ){
			changeLocation( $('input#new_location').val() );
		}
	});
	
	$('.getDirections').unbind();
	$('.getDirections').click(function(){
		      //$(this).parent().popup('close');
		      getDirectionsTo($(this).attr('lat'),$(this).attr('lng'));
		      
		      });
	
	
	$('#submitButton').unbind();
	$('#submitButton').click(function(){
		      //$(this).parent().popup('close');
		      facebook_login(function(){
		      		      location.href="/submit";
		      });
		      
		      });
	$('.editItem').unbind();
	$('.editItem').click(function(){
		      //$(this).parent().popup('close');
		      location.href="/submit?event_id=" + $(this).attr('event_id');
		      
		      });
	
	$('.deleteItem').unbind();
	$('.deleteItem').click(function(){
		      //$(this).parent().popup('close');
		      if ( confirm('Are you sure you want to PERMANENTLY delete this?') ){
		      	      location.href="/delete?event_id=" + $(this).attr('event_id');
		      }
		      
		      });
	
	
	$('.shareFacebook').unbind();
	$('.shareFacebook').click(function(){
		      //$(this).parent().popup('close');
		      _flyer_id = $(this).attr('flyer_id');
		       facebook_share(_flyer_id);
		      
		      });
	
	$('.shareTwitter').unbind();
	$('.shareTwitter').click(function(){
		      _flyer_id = $(this).attr('flyer_id');
		      window.open("http://twitter.com/home?status=http://www.flyerzero.com/item/?event_id=" + _flyer_id, '_blank');
		      
		      });
}
function changeLocation( location ) {
	$('input#new_location').val('Changing location...');
	$.get('/board/change_location/?location=' + location, function(data) {
		focusFlyer = "";
		$('#address').html(data);
		$('input#new_location').val('');
	});
}

function loadFlyerData(lat, lng) {
	if (!query_flyers)
		return;
	
	url = "/board/flyers/?lat="+lat+"&lng="+lng;
	$('span#flyer_distance').html("Loading Flyers...");
	$.get( url ,function(data) {

		$('#change_location').fadeOut("fast", function() {
			$('#address').fadeIn("fast", function() {}); //make sure it is visible
		}); // hide this.

		$('#content').html(data);

		registerEvents();
	});

}

function getUserLocation() {

	var timeoutVal = 10 * 1000;
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation,{ enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 });
}


function reloadLocation(){
	
	loadFlyerData(user_latitude, user_longitude);
}

function foundLocation(position) {
	user_latitude = position.coords.latitude;
	user_longitude = position.coords.longitude;
	findCountry(user_latitude, user_longitude);

	latitude = position.coords.latitude;
	longitude = position.coords.longitude;
	loadFlyerData(latitude, longitude);
}

function noLocation(error) {

	user_latitude = 38.025208;
	user_longitude = -78.488517;
	findCountry(user_latitude, user_longitude);

	latitude = 38.025208;
	longitude = -78.488517;
	
	loadFlyerData(latitude, longitude);
	
	if(error.code == 1) {
		alert('Looks like you\'ve declined location services! We need that. Meanwhile, here\'s a different zero!');
	} else {
		alert('We\'re having trouble finding your location, so here\'s a different zero!');
	}
}


function findCountry(lat, lng){
    // get the country we're in
    /*
    geocoder = new google.maps.Geocoder();
    latlng = new google.maps.LatLng(lat, lng);

    geocoder.geocode({'latLng': latlng}, function(results, status) {
	if (status == google.maps.GeocoderStatus.OK) {
	    if (results[0]) {
		for(method in results[0].address_components){
		    types = results[0].address_components[method].types
		    for(var index in types ){
			if(types[index] == 'country'){
			    user_country = results[0].address_components[method].short_name;
			}
		    }
		}
	    }
	}
     });
     */
}
function getDirectionsTo(_lat, _lng){
    baseURL = "http://maps.google.com";
    
    url = baseURL + "/maps?saddr=" + user_latitude + "," + user_longitude + "&daddr=" + _lat + "," + _lng;
    console.log(url);
    location.href=url;
}
