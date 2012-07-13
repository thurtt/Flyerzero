
var currentMarker = null;

function PreviousMarker(){
    var curfound = false;
    if (currentMarker != null){
        if (markers) {
            for (var i in markers) {
                if (curfound == true){
                    SetViewedMarker(i);
                    return;
                }
                if (i == currentMarker){
                    curfound = true;
                }
            }
        }
        
    }
    for (var i in markers){
        SetViewedMarker(i);
        return;
    }
    
}

function NextMarker(){
    var curfound = false;
    var keys = new Array();
    
    for (var k in markers) {
        keys.unshift(k);
    }
    
    if (currentMarker != null){
        if (markers) {
            for (var c = keys.length, n = 0; n < c; n++) {
                if (curfound == true){
                    SetViewedMarker(keys[n]);
                    return;
                }
                if (keys[n] == currentMarker){
                    curfound = true;
                }
            }
        }
        
    }
    for (var c = keys.length, n = 0; n < c; n++){
        SetViewedMarker(keys[n]);
        return;
    }
    
}
function ResetViewedMarker(){
    currentMarker = null;
    $('span#flyer_distance').html("0mi");
}
function SetViewedMarker(marker){
    $('span#flyer_distance').html(markers[marker].distance.toFixed(2) + "mi");
    markers[marker].setZIndex(9999);
    map.setZoom(17);
    map.setCenter(markers[marker].getPosition());
    if (currentMarker != null) {
        markers[currentMarker].setZIndex(9998);
    }
    currentMarker = marker;
    google.maps.event.trigger(markers[marker], 'click');
}

function ZoomIn(){
    map.setZoom(map.getZoom() + 1);
}

function ZoomOut(){
    if (map.getZoom() > 1)
        map.setZoom(map.getZoom() - 1);
}
