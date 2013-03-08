var venueList = {};
var errorList = [];
var submitState = 'error';
var uploadData = {};
var venue_search_ll = '';
var typeCheck = /\.(jpg|jpeg|png|gif)(?:[\?\#].*)?$/i;


// **** for init ****
function initSubmitForm(){
	// clear out any old form stuff
	//clearForm();
	$('#add_panel input#event_expiry').datepicker({ dateFormat: 'D, dd M yy', nextText: '', prevText: '' });
		$('#add_panel input#event_expiry').attr('readonly', 'readonly');

		$('#mini_dragdrop_area').unbind();
		$('#mini_dragdrop_area').click( function(){
			$('#submission_page').fadeIn("slow", function() {});
			$('#board_page').fadeOut("slow", function() {});
		});

		// submit for new event
		$('#submit_event').unbind();
		$('#submit_event').click(submitEvent);

		
		$('#clear_form').unbind();
		$('#clear_form').click( function(){
			clearForm();
			clearUploadArea();
		});
		
		// clear out flyer error box
		$('#flyer_error_box').unbind();
		$('#flyer_error_box').click(function(){$('#flyer_error_box').fadeOut('fast')});

		// autocomplete for event location
		$( "#event_loc" ).autocomplete({
			minLength: 3,
			source: function(req, add){venueSearch(req, add);},
			select: function(e, ui) {selectVenue(e, ui)},
			open: function(event, ui){useVenue(event, ui)}
		});

		// used for drag and drop file uploads
		attachFileUploader();

		$('#clone_event').unbind();
		$('#clone_event').click( function(){
			attachFileUploader();
			$('#event_event_id').val( eventId );
			$('#message_content').fadeOut();
			$('#response_container').fadeOut( function(){$('#form_content').fadeIn()});
		});

		$('#fresh_event').unbind();
		$('#fresh_event').click(function(){
			$('#dragdrop').html( dragdropPartial );
			clearForm();
			$('#event_event_id').val('');
			attachFileUploader();
			$('#message_content').fadeOut();
			
			$('#response_container').fadeOut( function(){$('#form_content').fadeIn()});
		})
		
		// some hacks for our file input hack...meta hacks
		$('#image_upload').mouseover( function(){
			$('#browse_button').removeClass('normal_hack');
			$('#browse_button').addClass('hover_hack');
		});
		$('#image_upload').mouseout( function(){
			$('#browse_button').removeClass('hover_hack');
			$('#browse_button').addClass('normal_hack');
		});

		// this will automatically bring up the submission form if we're
		// editing something
		setEditMode();
		$('#venue_search_location').unbind();
		$('#venue_search_location').click(function(){
		    $(this).hide();
		    $('#venue_search_location_edit').show();
		    $('#venue_search_location_edit input').select();
		    $('#venue_search_location_edit input').focus();
		});

		$('#venue_search_location_edit input').blur(function(){
		    updateSearchLocation();
		});

		$('#venue_search_location_edit input').keypress( function(event){
		    var keycode = (event.keyCode ? event.keyCode : event.which);
		    if(keycode == '13'){
			updateSearchLocation();
		    }
		});
}


// *** Form Cleanup ****
function clearForm(){
    //$('#event_email').val('');
    $('#event_expiry').val('');
    $('#event_loc').val('');
    $('#event_fbevent').val('');
    $('#event_media').val('');
    $('#flyer_photo').html('');
    $('#venue_icon').attr('src', '');
    $('#venue_name').html('');
    $('#venue_location').html('No venue chosen');
    $('#venue_icon').hide();
    uploadData = {};
}

function clearUploadArea(){
    $('#dragdrop_content').hide();
    $('#flyer_photo').html( '' );
    $('#dragdrop_text').show();
    $('#chosen_file').html('No file chosen');
    $('#dragdrop_content').addClass('drapdrop_area')
    $('#dragdrop_content').show();
}


// **** Form Submission ****
function submitEvent(e){
	e.preventDefault();
	console.log('hi');
    clearErrors();
    facebook_login(function(response){
    		    if( validateForm() ){
			    
    		    	    	
				if( editFlyer && !uploadData.submit ){
					console.log("submitting with post");
					$.post( $('form').attr('action'), $('form').serialize(), function(data){processResponse(data)});
				} else {
					console.log("submitting...");
					uploadData.submit();
				}
				$('#message_text').html('');
				$('#create_wait').show();
				$('#form_content').fadeOut(function(){
					$('#message_content').fadeIn();
				});
		    }
    });
}

function processResponse( text ){
	console.log("processResponse()");
    $('#response_container').hide();
    $('#create_wait').fadeOut(function(){
	    $('#message_text').html( text );
	    switch(submitState){

		case 'created':
		    location.href='/item?event_id=' + eventId;
		    break;

		case 'updated':
		    
		    location.href='/item?event_id=' + eventId;
		    break;

		case 'error':
		default:
		    $('#decision_widget').hide();
		    $('#response_container').fadeIn();
		    $('#message_content').delay( 8000 ).fadeOut(function(){
			$('#form_content').fadeIn()
			$('#decision_widget').show();
			$('#response_container').hide();
		    });
	    }
    });
}


// **** Form Validation ****
function validateForm(){

    validated = true;	    
    
    // check to see if an image has been selected
    if ( !uploadData.submit && !editFlyer ){
	//$('#dragdrop_text').addClass( 'error_text' );
	addError( $('#dragdrop_content') );
	validated = false;
    }

    // check for a valid file type
    if(!editFlyer && !typeCheck.test($('#chosen_file').html())){
		alert('Sorry, we only support image file types of jpg, png, and gif :(');
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
    if( $('#event_lat').val().length <= 0 ) {
    	    $('#event_lat').val(latitude);
    	    $('#event_lng').val(longitude);
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
	errorList = [];
}


// **** Upload Controls ****
function attachFileUploader(){
	if( !supportsDragDrop() ){
		$('#dragdrop_support').hide();
	}
	if( !supportsPreview() ) {
		$('#no_preview').show();
	}
    $('#image_upload').fileupload({
	dataType: 'html',
	url: '/events/create',
	dropZone: $('#dragdrop_content'),
	add: function( e, data ) {
	    $.each(data.files, function (index, file) {
			if(typeCheck.test(file.name)){
			    uploadData = data;
			    if( supportsPreview() ){
				console.log('File: ' + file);
				createImagePreview( file );
			    }
			    $('#chosen_file').html( file.name );
			} else {
			    $('#flyer_error_text').html('Sorry, but we only support the image types of jpeg, png, or gif :(');
			    $('#flyer_error_box').fadeIn('slow').delay(3000).fadeOut('slow');
			}
	    });

	},
	done: function( e, data ){
	    processResponse( data.result );
	},
	error: function( e, data ){
	    submitState = 'error';
	    processResponse( '<h1>A really ugly error has occurred :(</h1><p>We probably cocked something up pretty bad, but we will fix it right away!</p>');
	}
    });
}

function setEditMode(){
    if( editFlyer ){

	    editUrl = '/events/update';

	    // clean up our dragdrop area
	    $('#dragdrop_text').hide();
	    $('#dragdrop_content').removeClass('drapdrop_area');

	    // change the button text
	    $('#submit_event').val("Update Event");

	    // Format the ugly old Mysql date
	    date = $.datepicker.parseDate( 'yy-mm-dd', $('#event_expiry').val() );
	    $('#event_expiry').val( $.datepicker.formatDate( 'D, dd M yy', date ) );

	    // show the venue information
	    $('#venue_icon').show();

	    // change up the submission controller method
	    $('form').attr('action', editUrl);

	    // change it in the upload control in case someone changes
	    // flyer images
	    $('#image_upload').fileupload(
		'option',
		'url',
		editUrl);
	    $('form').removeAttr('data-remote');

	    // show the submission form
	    $('#submission_page').fadeIn("slow", function() {});
	    $('#board_page').fadeOut("slow", function() {});
    }
}

function supportsDragDrop(){
	if ( window.FileReader ) {
		return true;
	}
	return false;
}

function supportsPreview(){
	if( window.File && window.FileReader && window.FileList && window.Blob ){
		return true;
	}
	return false;
}

function createImagePreview( fileObj ) {
      $('#dragdrop_content').hide();
      $('#flyer_photo').html( '' );
      window.loadImage(
	    fileObj,
	    function (image) {
		if( image.type === "error" ){
		    console.log('error');
		}else{
		    console.log('image');
		    $('#dragdrop_text').hide();
		    $('#dragdrop_content').removeClass('drapdrop_area');
		    stuff = $('#flyer_photo').html( image );
		}
		$('#dragdrop_content').fadeIn();
	    },
	    {maxWidth: 300, maxHeight: 400}
      );
}


// **** Venue Search Control ****
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

function venueSearch( req, add ){
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
	    venueName = formatLocationText( val.name, val.address, val.cross_street );
	    venueLabel = formatListItem( val.name, val.address, val.cross_street );
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

function selectVenue(e, ui){
    // whichever item is selected, we need to record lat and lng info for it
    $.each(venueList, function(i, val){
	    if( formatLocationText( val.name, val.address, val.cross_street) == ui.item.value){
		$('#venue_name').html( val.name );
		$('#venue_location').html( ( val.address ? val.address : '' ) + ( val.cross_street ? ' ( ' + val.cross_street + ' )' : '' ));
		$('#event_lat').val( val.lat );
		$('#event_lng').val( val.lng );
		$('#event_venue_id').val( val.venue_id );
	    }
    });
}

function useVenue(event, ui){
    $("ul.ui-autocomplete li a").each(function(){
	var htmlString = $(this).html().replace(/&lt;/g, '<');
	htmlString = htmlString.replace(/&gt;/g, '>');
	$(this).html(htmlString);
    });
}

function updateSearchLocation(){
    if($('#venue_search_location').html() != $('#venue_search_location_edit input').val() ){
	$.getJSON('board/get_location', { 'location': $('#venue_search_location_edit input').val() },
		  function(data){
			if(data['city'] == null){
			    $('#venue_search_location').html('Location not found :(');
			} else {
			    venue_search_ll = data['lat'] + ', ' + data['lng'];
			    $('#venue_search_location_edit input').val(data['city'] + ', ' + data['state']);
			    $('#venue_search_location').html(data['city'] + ', ' + data['state']);
			}
		  });
	$('#venue_search_location').html('Changing location...');
    }
    $('#venue_search_location_edit').hide();
    $('#venue_search_location').show();
}