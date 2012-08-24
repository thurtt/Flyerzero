
//= require best_in_place

refresh_url = '';
var mainVenue;

$(document).ready(function() {
    $('.slideshow_container').cycle({
		fx: 'fade', // choose your transition type, ex: fade, scrollUp, shuffle, etc...
		before: function(currSlideElement, nextSlideElement, options, forwardFlag) {
		    $('#header').html(currSlideElement.getAttribute('data-date'));
		    venue_id = currSlideElement.getAttribute('data-venue-id');
		}
	});

    
    jQuery(".best_in_place").best_in_place();
    
    // autocomplete for event location
		$( "#event_loc" ).autocomplete({
			minLength: 3,
			source: function(req, add){box_venueSearch(req, add);},
			select: function(e, ui) {box_selectVenue(e, ui)},
			open: function(event, ui){box_useVenue(event, ui)}
		});
		
		$('#venue_search_location').click(function(){
		    $(this).hide();
		    $('#venue_search_location_edit').show();
		    $('#venue_search_location_edit input').select();
		    $('#venue_search_location_edit input').focus();
		});

		$('#venue_search_location_edit input').blur(function(){
		    box_updateSearchLocation();
		});

		$('#venue_search_location_edit input').keypress( function(event){
		    var keycode = (event.keyCode ? event.keyCode : event.which);
		    if(keycode == '13'){
			box_updateSearchLocation();
		    }
		});
		
		$('#venue_actual').click(function() { $('.whole_search').show(); });
		$('#save_changes').click(function() { updateConfig(); });
});



// **** Venue Search Control ****
function box_formatListItem( name, address, crossStreet ){
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

function box_formatLocationText( name, address, crossStreet ){
    formatStr = name
    if( address ){
	formatStr += ' ' + address;
    }
    if( crossStreet ){
	formatStr += ' (' + crossStreet + ')';
    }
    return formatStr;
}

function box_venueSearch( req, add ){
	
    // fire off our wait icon
    $('#search_wait').show();
    $('#foursquare_search_error').hide();

    if(venue_search_ll != ''){
	req['ll'] = venue_search_ll;
    }
    //pass request to server
    var jqxhr = $.getJSON("/board/venue", req, function(data) {

	//create array for response objects
	var suggestions = [];

	//process response
	venueList = data;
	$.each(venueList, function(i, val){
	    venueName = box_formatLocationText( val.name, val.address, val.cross_street );
	    venueLabel = box_formatListItem( val.name, val.address, val.cross_street );
	    suggestions.push({ label: venueLabel, value: venueName});
	});

	//pass array to callback
	add(suggestions);

	// remove wait icon
	$('#search_wait').hide();
    })
    .error(function(){
	// remove wait icon
	$('#search_wait').hide();
	 $('#foursquare_search_error').show().delay(30000).fadeOut();
    });
}

function box_selectVenue(e, ui){
    // whichever item is selected, we need to record lat and lng info for it
    $.each(venueList, function(i, val){
	    if( box_formatLocationText( val.name, val.address, val.cross_street) == ui.item.value){
	    	    mainVenue = val;
	    	    
		$('.venue_icon').attr( 'src',  val.icon );
		$('.venue_icon').show();
		$('.venue_name').html( val.name );
		$('.venue_location').html( ( val.address ? val.address : '' ) + ( val.cross_street ? ' ( ' + val.cross_street + ' )' : '' ));
		$('#event_lat').val( val.lat );
		$('#event_lng').val( val.lng );
		$('#event_venue_id').val( val.venue_id );
		$('#save_changes').show();
	    }
    });
}

function box_useVenue(event, ui){
	
    $("ul.ui-autocomplete li a").each(function(){
	var htmlString = $(this).html().replace(/&lt;/g, '<');
	htmlString = htmlString.replace(/&gt;/g, '>');
	$(this).html(htmlString);
    });
}

function box_updateSearchLocation(){
    if($('#venue_search_location').html() != $('#venue_search_location_edit input').val() ){
	$.getJSON('/board/get_location', { 'location': $('#venue_search_location_edit input').val() },
		  function(data){
			if(data['city'] == null){
			    $('#venue_search_location').html('Location not found :(');
			    $('#event_loc').hide();
			} else {
			    venue_search_ll = data['lat'] + ', ' + data['lng'];
			    $('#venue_search_location_edit input').val(data['city'] + ', ' + data['state']);
			    $('#venue_search_location').html(data['city'] + ', ' + data['state']);
			    $('#event_loc').show();
			}
		  });
	$('#venue_search_location').html('Changing location...');
    }
    $('#venue_search_location_edit').hide();
    $('#venue_search_location').show();
}
function updateConfig(){
	$.post('/zerobox/update/', {id: $('#box_id').val(), box: {config: configTOjson()} }, function(data){
			$('.whole_search').fadeOut('slow', function(){} );
	});
}
function configTOjson(){
	jsontext = '{';
	jsontext += '"ll":"' + mainVenue.lat + ',' + mainVenue.lng + '"';
	jsontext += ',"venue_id":"' + mainVenue.venue_id + '"';
	if ( $('#nearby').is(':checked') ){
		jsontext += ',"radius":60';
	}
	jsontext += '}';
	return jsontext;
}