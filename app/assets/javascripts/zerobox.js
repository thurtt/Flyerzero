refresh_url = '';

$(document).ready(function() {
    $('.slideshow_container').cycle({
		fx: 'fade', // choose your transition type, ex: fade, scrollUp, shuffle, etc...
		before: function(currSlideElement, nextSlideElement, options, forwardFlag) {
		    $('#header').html(currSlideElement.getAttribute('data-date'));
		    venue_id = currSlideElement.getAttribute('data-venue-id');
		}
	});
    
    $('#calendar').fullCalendar({
    		    
    dayClick: function() {
        alert($(this).find('.fc-day-number').html());
    },
    		    
    eventRender: function(event, element, view) {
    	    $('.fc-day' + (event['expiry'].split('-')[2] - 1)).css('background',"url("+event['imgURL']+")");
    	    $('.fc-day' + (event['expiry'].split('-')[2] - 1)).css('textShadow','-1px 0 1px black, 0 1px 1px black, 1px 0 1px black, 0 -1px 1px black');
    	    $('.fc-day' + (event['expiry'].split('-')[2] - 1)).css('color',"#fff");
    	element = null;
    },
    events: function(start, end, callback) {
    	    $('.fc-widget-content').css('color','black');
    	    $('.fc-widget-content').css('textShadow','');
    	    $('.fc-widget-content').css('background','');
        $.ajax({
            url: refresh_url,
            dataType: 'json',
            data: {
                start: Math.round(start.getTime() / 1000),
                end: Math.round(end.getTime() / 1000)
            },
            success: function(doc) {
                var events = [];
                $(doc).each(function() {
                    events.push({
                    	className: "zedcal calendar_" + $(this).attr('id'),
                        expiry: $(this).attr('expiry'),
                        title: $(this).attr('expiry'),
                        start: $(this).attr('expiry'),
                        imgURL: $(this).attr('map_photo') // will be parsed
                    });
                });
                callback(events);
            }
        });
    }
    });
    
    
});