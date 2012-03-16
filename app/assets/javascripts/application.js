// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require_tree .



var map;
var address;
var markers = [];
var uploadData = {};

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
	});

	initialize_map();

});

// disable the default drag and drop behavior
$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

function loadFlyerData(lat, lng) {
	$.get('flyers/?lat=' + lat + '&lng=' + lng ,function(data) {
		$('#content').html(data);
		$('#add_panel input#event_expiry').datepicker({ dateFormat: 'D, dd M yy' });
		$('#add_panel input#cancel').click( function(){
			$('#submit').fadeOut(function(){$('#kickstarter').fadeIn();});
			$('#dragdrop').fadeOut(function(){$('#flyer').fadeIn();});
		});

		// submit for new event
		$('#submit_event').click( function(){
			result = uploadData.submit();
		});

		// used for drag and drop file uploads
		$(function () {
			$('#image_upload').fileupload({
			    dataType: 'json',
			    url: '/events/create',
			    dropZone: $('#dragdrop_content'),
			    add: function( e, data ) {
				$.each(data.files, function (index, file) {
				    $('#image_file').html(file.name);
				    uploadData = data;
				    createImagePreview( file );
				    
				});
			    },
			    done: function( e, data ){
				$('#message_content').html( data.result );
			    }
			});
		});
	});

}


function initialize_map() {
	map = new google.maps.Map(document.getElementById('map_canvas'), {
          zoom: 15,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        });
	map.setCenter(new google.maps.LatLng(38.025208, -78.488517), 1);

	navigator.geolocation.getCurrentPosition(foundLocation, noLocation);

}
function clearMap() {
	if (markers) {
		for (i in markers) {
			markers[i].setMap(null);
		}
		markers.length = 0;
	}
}
function addUser() {
	addAddressToMap(address.latitude, address.longitude, '/assets/user.png');
}

function addAddressToMap(lat, lng, image) {
	point = new google.maps.LatLng(lat,lng);

        var locationmarker;
	var div = document.createElement('DIV');
        div.innerHTML = '<div class="map_flyer box"><img src="' + image + '" class="map_flyer"><div class="overlay box"></div><div class="arrow-down"></div></div>';

        locationmarker = new RichMarker({
          map: map,
          position: point,
          draggable: false,
          flat: true,
          anchor: RichMarkerPosition.BOTTOM,
          content: div
        });

	map.setCenter(point, 13);
	markers.push(locationmarker);
}


function foundLocation(position) {
	var lat = position.coords.latitude;
	var long = position.coords.longitude;
	address = position.coords;
	addUser();
	loadFlyerData(lat, long);

	//alert('Found location: ' + lat + ', ' + long);
}


function noLocation() {
	loadFlyerData(null,null);
	//alert('Could not find location');
}

function createImagePreview( fileObj ){
      $('#dragdrop_content').css('display', 'none');
      $('#dragdrop_content').html('');
      $('#dragdrop_content').removeClass('drapdrop_area');
      window.loadImage(
	    fileObj,
	    function (img) {
		$('#dragdrop_content').append(img);
		$('#dragdrop_content').fadeIn();
	    },
	    {maxWidth: 400, maxHeight: 500}
      );
}