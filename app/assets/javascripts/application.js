// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .
//= require webshims/minified/extras/modernizr-custom
//= require webshims/minified/polyfiller
//= require history_jquery

var map;
var latitude;
var longitude;
var user_latitude;
var user_longitude;
var user_country = 'US';
var markers = {};
var oMarkers = [];
var foursquare_markers = {};
var focusFlyer = '';

// This shouldn't go in $(document).ready()
$.webshims.setOptions('basePath', '/assets/webshims/minified/shims/');
$.webshims.polyfill();

$(document).ready(function() {

	$('#share_test').click(function(){
			reloadLocation();
		//facebook_share();
	});
	$('div.slideshow img:first').addClass('first');
	
	$('.submit_link').click( function(e) {

                // Prevents the default action to be triggered. 
                e.preventDefault();
                facebook_login(function(response){
                	$('#event_email').val(response.email);
                		
                	// Triggering bPopup when click event is fired
			$('#form_area').bPopup({
			    //modalClose: false,
			    opacity: 0.7,
			    //follow: [auto, auto],
			    positionStyle: 'fixed' //'fixed' or 'absolute'
			});	
                });

        });

	$('#address').click( function(){
		$('#address').fadeOut("fast", function() {
			$('#change_location').fadeIn("fast", function() {
				$('#new_location').focus();
			});
		});
	});

	$('#new_location').blur( function(){
		$('#change_location').fadeOut('fast', function() {
			$('#address').fadeIn("fast", function(){});
		});
	});


	$('button.change_location').click( function(){
		if ( $('input#new_location').val() != '' ){
			changeLocation( $('input#new_location').val() );
		}
	});
	$('input#new_location').keypress( function(event){
		var keycode = (event.keyCode ? event.keyCode : event.which);
		if(keycode == '13'){
			if ( $('input#new_location').val() != '' ){
				changeLocation( $('input#new_location').val() );
			}
		}
	});
	$('td#previous').unbind();
	$('td#next').unbind();
	$('td#previous').click( function(){PreviousMarker();});
	$('td#next').click( function(){NextMarker();});


	initialize_map();
	initSubmitForm();
	//setTimeout( "initialize_map();", 3000);

});

// disable the default drag and drop behavior
$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

function changeLocation( location ) {
	$('input#new_location').val('Changing location...');
	$.get('/board/change_location/?location=' + location, function(data) {
		focusFlyer = "";
		$('#address').html(data);
		$('input#new_location').val('');
		$('#board_link').show();
		$('#map_link').hide();
	});
}

function loadFlyerData(lat, lng) {
	if ( editFlyer ){
	    url = '/board/flyers/?id='+focusFlyer+'&lat=' + lat + '&lng=' + lng + '&validation=' + validation + '&event_id=' + eventId;
	} else {
	    url = '/board/flyers/?id='+focusFlyer+'&lat=' + lat + '&lng=' + lng;
	}

	$('span#flyer_distance').html("Loading Flyers...");
	$.get( url ,function(data) {

		

		$('#change_location').fadeOut("fast", function() {
			$('#address').fadeIn("fast", function() {}); //make sure it is visible
		}); // hide this.

		$('#content').html(data);

		$('.show_on_map').unbind();
		$('.show_on_map').click( function(){
				_marker = markers[$(this).attr( 'flyer_id')];
				map.setCenter(_marker.getPosition());
				google.maps.event.trigger(_marker, 'click');
		});

		if(!focusFlyer){
		  $('span#flyer_distance').html(formatDistance(0));
		}

		$('img#map_navigation').show();
	});

}

function initialize_map() {

	map = new google.maps.Map(document.getElementById('map_canvas'), {
          zoom: 15,
          disableDefaultUI: true,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        });
	map.setCenter(new google.maps.LatLng(38.025208, -78.488517), 1);
	var timeoutVal = 10 * 1000;
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation,{ enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 });
}

function clearMap() {
	if (markers) {
		for (var i in markers) {
			markers[i].setMap(null);
		}
		markers = {};
		oMarkers = [];
	}
	if (foursquare_markers) {
		for (var i in foursquare_markers) {
			foursquare_markers[i].setMap(null);
		}
		foursquare_markers = {};
	}
}

function closeInfoWindows() {
	if (markers) {
		for (var i in markers) {
			markers[i].infowindow.close();
		}
	}

	if (foursquare_markers) {
		for (var i in foursquare_markers) {
			foursquare_markers[i].infowindow.close();
		}
	}
}

function addUser() {
	marker = addAddressToMap(user_latitude, user_longitude, { small: '/assets/user_small.png', large: '/assets/user.png', text: 'We think you are physically here. <br /> <br />Philosophically, though, is another matter.'}, true);
	foursquare_markers["0"] = marker;
}

function addAddressToMap(lat, lng, data, person) {
	point = new google.maps.LatLng(lat,lng);

        var locationmarker;
        var distance = 100;
	var div = document.createElement('DIV');
        div.innerHTML = '<div class="map_flyer"><div class="map_flyer_contents" style="position:relative; background-image: url(\'' + data["large"] + '\'); background-size: cover;"><div class="arrow-down"></div></div>';

        locationmarker = new RichMarker({
          map: map,
          position: point,
          draggable: false,
          flat: true,
          anchor: RichMarkerPosition.BOTTOM,
          content: div
        });
        info = '<div style="text-align:center">';
        info += '<a href="' + data["original"] + '" target="_new">';
        info += '<div style="position:relative; background-image: url(\'' + data["large"] + '\'); background-size: cover;" class="map_flyer_info">';
        info += '<div class="flyer_date">' + data["expiry"] + '</div>';
        info += '</div>';
        info += '</a>';
        if ( person ) {
        }
        else {
		if ( $(data["text"]).filter("iframe").length == 0 ){
			info += '<div style="float:right;" class="map_data"><div class="alert_header"><br /><br /><br />This promoter hasn\'t<br />included any media yet!<br /><br /></div></div>';
		
		}
		else {
			info += '<div style="float:right;" class="map_data">' + $("<div></div>").append($(data["text"]).filter("iframe").first()).html() + '</div>';
		
		}

		if (data["get_distance_from"] != undefined){
			distance = parseFloat(data["get_distance_from"]);
		}

		if ( data["flyer_id"] != undefined ){

			if ( data["profile"] != undefined ){
				info += '<a href="/profile/view/' + data["profile"] + '" target="_blank">';
				info += '<div style="background-image:url(\'' + data["gravatar"] + '&s=200\'); background-position: 0px -60px;" class="bullet_button"><div class="bullet_text">Promoter</div></div></a>';
			}
			if ( (data["fbevent"] != undefined ) && ( data["fbevent"] != "" )){
				var event_url = "";
				if ( data["fbevent"].indexOf("http") < 0 ){
					event_url = 'http://';
				}
				event_url += data["fbevent"];
				info += '<a href="' + event_url + '" target="_blank">';
				info += '<div style="background-image:url(\'/assets/fb_rsvp.png\');" class="bullet_button"><div class="bullet_text">RSVP</div></div></a>';
			}
			else {
				info += '<div class="bullet_button"><div class="bullet_fail">No event link</div></div>';
			}
			/*
			info += '<a href="http://www.facebook.com/sharer.php?&u=http://www.flyerzero.com/?flyer=' + data["flyer_id"] + '&t=Flyer Zero Event" target="_blank" onclick="return getSharePoints(\'' + data["flyer_id"] + '\');">';
			info += '<div style="background-image:url(\'/assets/fb_scrn.png\');" class="bullet_button"><div class="bullet_text">SHARE</div></div></a>';
			*/
		}
        }
        info += '</div>'

        var infowindow = new google.maps.InfoWindow(
	{
		content: info
	});
	locationmarker.flyer_id = data["flyer_id"];
        locationmarker.distance = distance;
        locationmarker.person = person;
        locationmarker.venue_id = data["venue_id"];
        google.maps.event.addListener(locationmarker, 'click', function() {
                //closeInfoWindows();
                if ( person == false) {
                	History.pushState({foo: "bar"}, "Flyer Zero", "?flyer=" + locationmarker.flyer_id);
                	SetViewedMarkerNoClick(locationmarker);
                	map.setCenter(locationmarker.getPosition());
                	//infowindow.open(map,locationmarker);
                }
                else {
                	History.pushState({foo: "bar"}, "Flyer Zero", "/");
                	map.setCenter(locationmarker.getPosition());
                }
        });

        locationmarker.infowindow = infowindow;

	map.setCenter(point, 13);
	return locationmarker;
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
	addUser();
	loadFlyerData(latitude, longitude);
}

function noLocation(error) {

	user_latitude = 38.025208;
	user_longitude = -78.488517;
	findCountry(user_latitude, user_longitude);

	latitude = 38.025208;
	longitude = -78.488517;
	addUser();
	
	loadFlyerData(latitude, longitude);
	
	if(error.code == 1) {
		alert('Looks like you\'ve declined location services! We need that. Meanwhile, here\'s a different zero!');
	} else {
		alert('We\'re having trouble finding your location, so here\'s a different zero!');
	}
}

function MoveTo( id, x, y, func ){
    $(id).animate( { left: x, top: y }, 'swing', func );
}

function getSharePoints(verification){
	$.get('/events/share/' + verification, function(data){} );
	return true;
}

function showAbout(){
	// Our about presentaion
	$('#jmpress').jmpress({
	    viewPort:{ width: 800,
		       height: 600,
		    },
	    hash:{ use: false }
	});
	$('#about_page').fadeIn("slow", function() {});
	$('#board_page').fadeOut("slow", function() {});
	$('#submission_page').fadeOut("slow", function(){});
}

function findCountry(lat, lng){
    // get the country we're in
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
}
