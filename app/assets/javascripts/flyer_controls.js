
var currentMarker = null;

function PreviousMarker(){
    var curfound = false;
    if (currentMarker != null){
        if (oMarkers) {
            for (var i in oMarkers) {
                if (curfound == true){
                    SetViewedMarker(oMarkers[i]);
                    return;
                }
                if (oMarkers[i] == currentMarker){
                    curfound = true;
                }
            }
        }

    }
    for (var i in oMarkers){
        SetViewedMarker(oMarkers[i]);
        return;
    }

}

function NextMarker(){

	var reversed = [];
	reversed = oMarkers.slice(0);
	reversed.reverse();

    var curfound = false;
    if (currentMarker != null){
        if (reversed) {
            for (var i in reversed) {
                if (curfound == true){
                    SetViewedMarker(reversed[i]);
                    return;
                }
                if (reversed[i] == currentMarker){
                    curfound = true;
                }
            }
        }

    }
    for (var i in reversed){
        SetViewedMarker(reversed[i]);
        return;
    }

}
function ResetViewedMarker(){
    currentMarker = null;
    $('span#flyer_distance').html(formatDistance(0));
}
function SetViewedMarkerNoClick(marker){
    $('span#flyer_distance').html(formatDistance(marker.distance));
    marker.setZIndex(9999);
    map.setZoom(17);
    map.panTo(marker.getPosition());
    map.panBy(0, -100);
    if (currentMarker != null) {
        currentMarker.setZIndex(9998);
    }
    currentMarker = marker;
}

function SetViewedMarker(marker){
    $('span#flyer_distance').html(formatDistance(marker.distance));
    marker.setZIndex(9999);
    map.setZoom(17);
    map.panTo(marker.getPosition()); 
    map.panBy(0, -100);   
    if (currentMarker != null) {
        marker.setZIndex(9998);
    }
    currentMarker = marker;
    google.maps.event.trigger(marker, 'click');
    setVenueInfo(marker.venue_name, marker.venue_location, marker.venue_icon);
}

function ZoomIn(){
    map.setZoom(map.getZoom() + 1);
}

function ZoomOut(){
    if (map.getZoom() > 1)
        map.setZoom(map.getZoom() - 1);
}

function formatDistance(inMiles){
    if(user_country.toUpperCase() == "US" || user_country.toUpperCase() == "GB"){
	return inMiles ? inMiles.toFixed(2) + "mi" : "0mi";
    } else {
	inKms = inMiles * 1.609344;
	return inKms ? inKms.toFixed(2) + "km" : "0km";
    }
}

function setVenueInfo(name, address, icon) {
    $('table#venue_table').hide();
    $('td#vt_icon img').attr('src', icon);
    $('td#vt_name').html(name);
    $('td#vt_location').html(address);
    $('table#venue_table').fadeIn(function() {});
}
