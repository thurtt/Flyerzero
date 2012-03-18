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
var venueList = {};

$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');



	$('#submit_link').click( function(){
		$('img.branding').animate( { right: '+=50' }, 'swing', null );
		$('#content').fadeToggle("slow", "linear");
	});

	//initialize_map();
	setTimeout( "initialize_map();", 3000);

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

		// autocomplete for event location
		$( "#event_loc" ).autocomplete({
			source: function(req, add){

			    //pass request to server
			    $.getJSON("/board/venue", req, function(data) {

				//create array for response objects
				var suggestions = [];

				//process response
				venueList = data;
				$.each(venueList, function(i, val){
				    venueName = val.name + ' ' + (val.address ? '' : ( ' ' + val.address ) ) + (val.cross_street ? '' : (' (' + val.cross_street + ')') );
				    venueLabel = formatListItem( val.name, val.address, val.cross_street );
				    suggestions.push({ label: venueLabel, value: venueName});
				});

				//pass array to callback
				add(suggestions);
			    });
			},

			select: function(e, ui) {
				// whichever item is selected, we need to record lat and lng info for it
				$.each(venueList, function(i, val){
					if( formatListItem( val.name, val.address, val.cross_street) == ui.item.value){
					    $('#event_lat').val( val.lat );
					    $('#event_lng').val( val.lng );
					    $('#event_venue_id').val( val.venue_id );
					}
				});
			},

			open: function(event, ui){
				$("ul.ui-autocomplete li a").each(function(){
					var htmlString = $(this).html().replace(/&lt;/g, '<');
					htmlString = htmlString.replace(/&gt;/g, '>');
					$(this).html(htmlString);
				});
			}
		});

		/*$('.slideshow').cycle({
			fx: 'shuffle',
			timeout: 3000,
			speedIn:  500
		});

		*/

		$(function () {
			$(".anyClass").jCarouselLite({
				btnNext: ".next",
				btnPrev: ".prev",
				visible: 5,
				//scroll:5
				auto: 800,
				speed: 1000
			});
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
	var timeoutVal = 10 * 1000 * 1000;
	navigator.geolocation.getCurrentPosition(foundLocation, noLocation,{ enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 });

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

function formatListItem( name, address, crossStreet ){
    formatStr = '<div class="venue_name">' + name + '</div>';
    if( address || crossStreet ){
	formatStr += '<div class="venue_details">'
	if( address ){
	    formatStr += address;
	}
	if( crossStreet ){
	    formatStr += ' (' + crossStreet + ')';
	}
	formatStr += '</div>';
    }
    return formatStr;
}

function MoveTo( id, x, y, func ){
    $(id).animate( { left: x, top: y }, 'swing', func );
}