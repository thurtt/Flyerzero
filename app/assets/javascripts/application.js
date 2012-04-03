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
var latitude;
var longitude;
var markers = {};
var uploadData = {};
var venueList = {};
var focusFlyer = '';
var errorList = [];

$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');



	/*$('#submit_link').click( function(){
		$('#submission_page').fadeToggle("slow", "linear");
		$('#board_page').fadeToggle("slow", "linear");
	});*/

	$('#map_link').click( function(){
		$('#board_page').fadeOut("slow", function() {});
		$('#submission_page').fadeOut("slow", function() {});
	});
	$('#board_link').click( function(){
		$('#board_page').fadeIn("slow", function() {});
		$('#submission_page').fadeOut("slow", function() {});
	});

	$('#submit_link').click( function(){
		$('#submission_page').fadeIn("slow", function() {});
		$('#board_page').fadeOut("slow", function() {});
	});
	$('#address').click( function(){
		$('#address').fadeOut("fast", function() {
			$('#change_location').fadeIn("fast", function() {});
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

	initialize_map();
	//setTimeout( "initialize_map();", 3000);

});

// disable the default drag and drop behavior
$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

function changeLocation( location ) {
	$('input#new_location').val('Changing location...');
	$.get('/board/change_location/?location=' + location, function(data) {
		$('#address').html(data);
	});
}

function loadFlyerData(lat, lng) {
	$.get('flyers/?id='+focusFlyer+'&lat=' + lat + '&lng=' + lng ,function(data) {

		// clear out any old form stuff
		clearForm();

		$('#change_location').fadeOut("fast", function() {
			$('#address').fadeIn("fast", function() {}); //make sure it is visible
		}); // hide this.

		$('#content').html(data);

		$('span.show_on_map').click( function(){
			$('#submission_page').hide("fast", function() {});
			$('#board_page').fadeOut("slow", function() {});
				_marker = markers[$(this).attr( 'flyer_id')];
				map.setCenter(_marker.getPosition());
				google.maps.event.trigger(_marker, 'click');
		});


		$('#add_panel input#event_expiry').datepicker({ dateFormat: 'D, dd M yy', nextText: '', prevText: '' });
		$('#add_panel input#event_expiry').attr('readonly', 'readonly');

		$('#mini_dragdrop_area').click( function(){
			$('#submission_page').fadeIn("slow", function() {});
			$('#board_page').fadeOut("slow", function() {});
		});

		// submit for new event
		$('#submit_event').click( function(){
			    clearErrors();
			    if( validateForm() ){
				uploadData.submit();
				$('#message_text').html('');
				$('#create_wait').show();
				$('#form_content').fadeOut(function(){
					$('#message_content').fadeIn();
				});
			    }
		});

		// autocomplete for event location
		$( "#event_loc" ).autocomplete({
			minLength: 3,
			source: function(req, add){

			    //pass request to server
			    $.getJSON("/board/venue", req, function(data) {

				//create array for response objects
				var suggestions = [];

				//process response
				venueList = data;
				$.each(venueList, function(i, val){
				    venueName = formatLocationText( val.name, val.address, val.cross_street );
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
					if( formatLocationText( val.name, val.address, val.cross_street) == ui.item.value){
					    $('#venue_icon').attr( 'src',  val.icon );
					    $('#venue_name').html( val.name );
					    $('#venue_location').html( val.address + ( val.cross_street ? ' ( ' + val.cross_street + ' )' : '' ));
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
			attachFileUploader();
		});
		$('#clone_event').click( function(){
			attachFileUploader();
			$('#event_event_id').val( eventId );
			$('#response_container').fadeOut( function(){$('#form_content').fadeIn()});
		});

		$('#fresh_event').click(function(){
			clearForm();
			$('#dragdrop').html( dragdropPartial );
			attachFileUploader();
			$('#response_container').fadeOut( function(){$('#form_content').fadeIn()});
		})
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
		for (var i in markers) {
			markers[i].setMap(null);
		}
		markers = {};
	}
}
function addUser() {
	marker = addAddressToMap(latitude, longitude, { small: '/assets/user.png', large: '/assets/user.png', text: 'We think you are physically here. <br /> <br />Philosophically, though, is another matter.'});
	markers["0"] = marker;
}

function addAddressToMap(lat, lng, data) {
	point = new google.maps.LatLng(lat,lng);

        var locationmarker;
	var div = document.createElement('DIV');
        div.innerHTML = '<div class="map_flyer box"><img src="' + data["small"] + '" class="map_flyer"><div class="overlay box"></div><div class="arrow-down"></div></div>';

        locationmarker = new RichMarker({
          map: map,
          position: point,
          draggable: false,
          flat: true,
          anchor: RichMarkerPosition.BOTTOM,
          content: div
        });
        info = '<img src="' + data["large"] + '" class="map_flyer_info">';
        if ( data["text"] != undefined ){
        	info += '<div style="float:right;padding-left:7px;">' + data["text"] + '</div>';
        }
        var infowindow = new google.maps.InfoWindow(
	{
		content: info
	});


        google.maps.event.addListener(locationmarker, 'click', function() {
		//alert('hi');
		map.setZoom(16);
		map.setCenter(locationmarker.getPosition());
		infowindow.open(map,locationmarker);
        });

	map.setCenter(point, 13);
	return locationmarker;
}


function foundLocation(position) {
	latitude = position.coords.latitude;
	longitude = position.coords.longitude;
	addUser();
	loadFlyerData(latitude, longitude);
}


function noLocation() {
	loadFlyerData(38.025208, -78.488517);
}

function createImagePreview( fileObj ) {
      $('#dragdrop_content').css('display', 'none');
      $('#dragdrop_text').hide();
      $('#dragdrop_content').removeClass('drapdrop_area');
      window.loadImage(
	    fileObj,
	    function (img) {
		$('#flyer_photo').append(img);
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
function formatLocationText( name, address, crossStreet ){
    formatStr = name
    if( address ){
	formatStr += ' ' + address;
    }
    if( crossStreet ){
	formatStr += ' (' + crossStreet + ')';
    }
    return formatStr;
}

function MoveTo( id, x, y, func ){
    $(id).animate( { left: x, top: y }, 'swing', func );
}

function clearForm(){
    $('#event_email').val('');
    $('#event_expiry').val('');
    $('#event_loc').val('');
    $('#image_file').html('');
    $('#venue_icon').attr('src', '');
    $('#venue_name').html('');
    $('#venue_location').html('No venue chosen');
    uploadData = {};
}

function attachFileUploader(){
    $('#image_upload').fileupload({
	dataType: 'script',
	url: '/events/create',
	dropZone: $('#dragdrop_content'),
	add: function( e, data ) {
	    $.each(data.files, function (index, file) {
		uploadData = data;
		createImagePreview( file );
	    });
	},
	done: function( e, data ){
	    eval( data.result );
	},
	error: function( e, data ){
	    submitStatus( '<h1>A really ugly error has occurred :(</h1><p>We probably cocked something up pretty bad, but we will fix it right away!</p>');
	}
    });
}

function validateForm(){

    validated = true;

    // check to see if an image has been selected
    if ( !uploadData.submit ){
	//$('#dragdrop_text').addClass( 'error_text' );
	addError( $('#dragdrop_content') );
	validated = false;
    }

    // check for a valid email address
    if($('#event_email').val().length <= 0) {
	addError( $('#event_email') );
	validated = false;
    }

    // check for a valid date
    if( $('#event_expiry').val().length <= 0 ) {
	addError( $('#event_expiry') );
	validated = false;
    }

    // check for a valid location
    if( $('#event_venue_id').val().length <= 0 ) {
	addError( $('#event_loc') );
	validated = false;
    }

    return validated;
}

function addError( item ){
	item.addClass( 'error_bg' );
	errorList.push( item );
}

function clearErrors(){
	$.each(errorList, function(i, val) {
	    val.removeClass( 'error_bg' );
	});
	//$('#dragdrop_text').removeClass( 'error_text' );
	errorList = [];
}

function submitStatus( text ){
    $('#response_container').hide();
    $('#create_wait').fadeOut(function(){
	    $('#message_text').html( text );
	    $('#response_container').fadeIn();
    });
}