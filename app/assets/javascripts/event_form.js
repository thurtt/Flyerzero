var venueList = {};
var errorList = [];
var submitState = 'error';
var uploadData = {};


// *** Form Cleanup ****
function clearForm(){
    $('#event_email').val('');
    $('#event_expiry').val('');
    $('#event_loc').val('');
    $('#event_fbevent').val('');
    $('#flyer_photo').html('');
    $('#venue_icon').attr('src', '');
    $('#venue_name').html('');
    $('#venue_location').html('No venue chosen');
    $('#venue_icon').hide();
    uploadData = {};
}


// **** Form Submission ****
function submitEvent(){
    clearErrors();
    if( validateForm() ){
	if( editFlyer && !uploadData.submit ){
		$.post( $('form').attr('action'), $('form').serialize(), function(data){processResponse(data)});
	} else {
		uploadData.submit();
	}
	$('#message_text').html('');
	$('#create_wait').show();
	$('#form_content').fadeOut(function(){
		$('#message_content').fadeIn();
	});
    }
}

function processResponse( text ){
    $('#response_container').hide();
    $('#create_wait').fadeOut(function(){
	    $('#message_text').html( text );
	    switch(submitState){

		case 'created':
		    $('#response_container').fadeIn();
		    break;

		case 'updated':
		    $('#decision_widget').hide();
		    $('#response_container').fadeIn();
		    $('#message_content').delay( 4000 ).fadeOut(function(){
			reHost = /(http:\/\/.+?)\/|$/;
			root = reHost.exec(document.URL)[1];
			window.location.replace( root + '/?flyer=' + flyerId);
		    });
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
		uploadData = data;
		if( supportsPreview() ){
		    createImagePreview( file );
		}
		$('#chosen_file').html( file.name );
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
      $('#dragdrop_content').css('display', 'none');
      $('#dragdrop_text').hide();
      $('#dragdrop_content').removeClass('drapdrop_area');
      window.loadImage(
	    fileObj,
	    function (image) {
		if( image.type === "error" ){
		    //skippy
		}else{
		    stuff = $('#flyer_photo').html( image );
		}
		$('#dragdrop_content').fadeIn();
	    },
	    {maxWidth: 400, maxHeight: 500}
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

	// remove wait icon
	$('#search_wait').hide();
    });
}

function selectVenue(e, ui){
    // whichever item is selected, we need to record lat and lng info for it
    $.each(venueList, function(i, val){
	    if( formatLocationText( val.name, val.address, val.cross_street) == ui.item.value){
		$('#venue_icon').attr( 'src',  val.icon );
		$('#venue_icon').show();
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