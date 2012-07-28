var main_url = '';

function loadCalendar(_url){
	
	
    refresh_url = _url;
    $('body').append("<div id='calendar'></div><div id='day_detail'></div>");
    
    $('#calendar').fullCalendar({
    		    
    dayClick: function() {
        //alert($(this).find('.fc-day-number').html());
    },
    eventClick:function(calEvent, jsEvent, view) {
        getForDay(calEvent.start);

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
                $('#day_detail').html('');
            }
        });
    }
    });
}

function getForDay(date, _url){
	$('#day_detail').html('Loading...');
	refresh_url = _url;
	$.ajax({
            url: refresh_url,
            dataType: 'json',
            data: {
                start: $.fullCalendar.formatDate( date, "yyyy-MM-dd" ),
                end: $.fullCalendar.formatDate( date, "yyyy-MM-dd" )
            },
            success: function(doc) {
            	info = '';
                map_markers = '';
                i = 1;
                $(doc).each(function() {
                		
                		map_markers += 'markers=color:blue%7Clabel:' + i.toString() + '%7C' + $(this).attr('lat') + ',' + $(this).attr('lng') +  '&';
				i++;
				
                		//include image.
                		info += '<a href="/?flyer=' + $(this).attr('id') + '" target="_new"><img src="' + $(this).attr('map_photo') + '" class="flyer_info"></a>';
                		
                });
                map = '<img src="http://maps.googleapis.com/maps/api/staticmap?' + map_markers + 'zoom=14&size=600x300&key=AIzaSyDgDc6rdIUKqZlIPRZFbCveT1QWTncTDzE&sensor=true" class="bullet_map"/>';
		whole = '<div class="event">' + map + info + '</div>';
                $('#day_detail').html(whole);
            }
        });
}
