function loadCalendar(_url){
	
	
    refresh_url = _url;
    $('body').append("<div id='calendar'></div>");
    
    $('#calendar').fullCalendar({
    		    
    dayClick: function() {
        //alert($(this).find('.fc-day-number').html());
    },
    		    
    eventRender: function(event, element, view) {
    	    element.html("<div class='fc-item'><span class='myday'>"+ (event['expiry'].split('-')[2] ) + "</span></div>");
    	    element.find("div").css('background',"url("+event['imgURL']+")");
    },
    events: function(start, end, callback) {
    	    $('.fc-widget-content').css('color','black');
    	    $('.fc-widget-content').css('textShadow','');
    	    $('.fc-widget-content').css('background','');
        $.ajax({
            url: refresh_url,
            dataType: 'json',
            data: {
                start: $.fullCalendar.formatDate( start, "yyyy-MM-dd" ),
                end: $.fullCalendar.formatDate( end, "yyyy-MM-dd" )
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
}
