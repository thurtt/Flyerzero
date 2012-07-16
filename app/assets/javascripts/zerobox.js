refresh_url = '';

$(document).ready(function() {
	loadCalendar(document.location);// load with our url.
		
    $('.slideshow_container').cycle({
		fx: 'fade', // choose your transition type, ex: fade, scrollUp, shuffle, etc...
		before: function(currSlideElement, nextSlideElement, options, forwardFlag) {
		    $('#header').html(currSlideElement.getAttribute('data-date'));
		    venue_id = currSlideElement.getAttribute('data-venue-id');
		}
	});

    
    
});