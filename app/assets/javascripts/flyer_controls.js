
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
    $('span#flyer_distance').html(marker.distance.toFixed(2) + "mi");
    marker.setZIndex(9999);
    map.setZoom(17);
    map.setCenter(marker.getPosition());
    if (currentMarker != null) {
        currentMarker.setZIndex(9998);
    }
    currentMarker = marker;
}

function SetViewedMarker(marker){
    $('span#flyer_distance').html(formatDistance(marker.distance));
    marker.setZIndex(9999);
    map.setZoom(17);
    map.setCenter(marker.getPosition());
    if (currentMarker != null) {
        marker.setZIndex(9998);
    }
    currentMarker = marker;
    google.maps.event.trigger(marker, 'click');
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
