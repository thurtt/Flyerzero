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
//= require fancybox

var latitude;
var longitude;
var user_latitude;
var user_longitude;
var user_country = 'US';
var query_flyers = true;


$(document).ready(function() {
	$('div.slideshow img:first').addClass('first');
	
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

	$(".fancybox").fancybox();
	$(".fancybox-effects-b").fancybox({
				openEffect  : 'none',
				closeEffect	: 'none',

				helpers : {
					title : {
						type : 'over'
					}
				}
			});
	$(".fancybox-effects-c").fancybox({
		wrapCSS    : 'fancybox-custom',
		closeClick : true,

		openEffect : 'none',

		helpers : {
			title : {
				type : 'inside'
			},
			overlay : {
				css : {
					'background' : 'rgba(238,238,238,0.85)'
				}
			}
		}
	});

	// Remove padding, set opening and closing animations, close if clicked and disable overlay
	$(".fancybox-effects-d").fancybox({
		padding: 0,

		openEffect : 'elastic',
		openSpeed  : 150,

		closeEffect : 'elastic',
		closeSpeed  : 150,

		closeClick : true,

		helpers : {
			overlay : null
		}
	});
	console.log("fancy");
	setUpLocationLinks();
	$('#address_container a, span').hover(function(){
			$('#menu_help').html($(this).attr('data-title'));
	});
	$("#address_container").hover(
		function(){
		  $('#menu_help').filter(':not(:animated)').animate({
		     marginTop:'41px'
		  },'fast');
		// This only fires if the row is not undergoing an animation when you mouseover it
		},
		function() {
		  $('#menu_help').animate({
		     marginTop:'0px'
		  },'fast');
		});
	$( "#fbcheck" ).button();
});

// disable the default drag and drop behavior
$(document).bind('drop dragover', function (e) {
    e.preventDefault();
});

function registerEvents(){
	$('#login').unbind('click');
	$('#login').click(function(){
			facebook_login(function(){
				location.href="/";
			});
	});
	
	$('#logout').unbind('click');
	$('#logout').click(function(){
			facebook_logout();
	});
	
	$('button.change_location').unbind();
	$('button.change_location').click( function(){
		newloc = $(this).parent().find('input#new_location').val();
		
		if ( newloc != '' ){
			changeLocation( newloc );
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

	$('.hashtag').unbind();
	$('.hashtag').click(function(e) {
		location.href = '/?hashtag=' + encodeURIComponent($(e.target).attr('tag'));
		e.stopPropagation();
	});

	$('.title_link').unbind();
	$('.title_link').click(function(e) {
		location.href=$(e.target).attr('href');
	});
	
	console.log("your mom");
}
function changeLocation( location ) {
	$('input#new_location').val('Changing location...');
	$.get('/board/change_location/?location=' + location, function(data) {
		focusFlyer = "";
		$('#response_dump').html(data);
		$('input#new_location').val('');
	});
}

function loadFlyerData(lat, lng) {
	if (!query_flyers)
		return;
	
	url = "/board/flyers/?lat="+lat+"&lng="+lng;
	if(hashtag) {
		url += "&hashtag=" + encodeURIComponent(hashtag); 
	}
	$('span#flyer_distance').html("Loading Flyers...");
	$.get( url ,function(data) {

		$('#content').html(data);
		
		$('#temporalShift').show();
		
		$(window).scroll(function () {
				bod = $(jQuery.browser.webkit ? "body": "html");
			if ( bod.scrollTop() < $(".future:last").offset().top ){
				$('#temporalImg').attr('src','/assets/future_background.png');
				$('#temporalImg').show();
			}
			else if ( bod.scrollTop() > $(".past:eq(5)").offset().top ){
				$('#temporalImg').attr('src','/assets/history_background.png');
				$('#temporalImg').show();
			}
			else if ( bod.scrollTop() > $(".past:first").offset().top ){
				$('#temporalImg').attr('src','/assets/current_background.png');
				$('#temporalImg').show();
			}
			if ( bod.scrollTop() < $(".future:eq(0)").offset().top ){
				
				$('#temporalImg').hide();
			}
			else {
				
				$('#temporalImg').show();
			}
		});
		if ( $(".future:last").size() > 0 ) {
			$(jQuery.browser.webkit ? "body": "html").animate({
				 scrollTop: $(".future:last").offset().top
			}, 1);
		}
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

function setUpLocationLinks() {
    var locationLinks = $("#address");
    var mapImage = $("#map_image_container img.map_image");
    var mapImageContainer = $("#map_image_container");
    var mapFancybox = function() {
       $.fancybox(
            {
                "showCloseButton" : true,
                "hideOnContentClick" : true,
                "titlePosition"  : "inside",
                "content" : $("#map_image_container").html()
            }
        );
        
    }
    locationLinks.click(
        function() {
            var clickedLink = $(this);
            mapImage.attr("src", '').unbind('load');
            mapImage.attr("src", clickedLink.attr("href")).load(
                function() {
                    mapFancybox();
                    registerEvents();
                }
            );
            if(mapImage.complete) {
                mapImage.triggerHandler("load");
            }
            return false;
        }
    );
}
