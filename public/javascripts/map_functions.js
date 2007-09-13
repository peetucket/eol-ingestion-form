	var marker;
	var circleLine;	
	var circleFilled;
		
	function getCoords() {
		// call remote function to geocode entered address
		new Ajax.Request('/observation/ajax_geocode_location', {asynchronous:true, evalScripts:true, method:'post', onComplete:function(request){hideAjaxIndicator();}, onLoading:function(request){showAjaxIndicator();}, parameters:Form.serialize('formDIV')});
	}

	function ajaxUpdateMap() {
		// call remote function to update map location
		new Ajax.Request('/observation/ajax_update_map', {asynchronous:true, evalScripts:true, method:'post', onComplete:function(request){hideAjaxIndicator();}, onLoading:function(request){showAjaxIndicator();}, parameters:Form.serialize('formDIV')});
	}
	
	function LatLonDegrees(LatDeg,LatMin,LatSec,LatDirection,LonDeg,LonMin,LonSec,LonDirection) {
		// structure for storing lat lon in degrees minutes seconds
		this.LatDeg=LatDeg;
		this.LatMin=LatMin;
		this.LatSec=LatSec;
		this.LatDirection=LatDirection;
		this.LonDeg=LonDeg;
		this.LonMin=LonMin;
		this.LonSec=LonSec;
		this.LonDirection=LonDirection;
		}		
		
    function convertLatLonToDegrees (LatDecimal,LonDecimal) {
		// convert latitude and longitude in decimal format to the latLonDegrees structure

		if (LatDecimal < 0) {LatDirection='S';} else {LatDirection='N';}
		if (LonDecimal < 0) {LonDirection='W';} else {LonDirection='E';}
		
		lat = Math.abs(LatDecimal);
        LatDeg = Math.floor(lat);
        LatMin = Math.floor((lat-LatDeg)*60);
        LatSec =  (Math.round((((lat - LatDeg) - (LatMin/60)) * 60 * 60) * 100) / 100 ) ;
		 	  
        lon = Math.abs(LonDecimal);
		LonDeg = Math.floor(lon);
        LonMin = Math.floor((lon-LonDeg)*60);
        LonSec = (Math.round((((lon - LonDeg) - (LonMin / 60 )) * 60 * 60) * 100 ) / 100);

		convertedLatLon = new LatLonDegrees(LatDeg,LatMin,LatSec,LatDirection,LonDeg,LonMin,LonSec,LonDirection);
		
		return convertedLatLon;
	}
		
		
	function updateLatLonDegrees() {
	    
	    // go from decial to deg, min, sec
		lat=$('entry_lat').value;
		lon=$('entry_lon').value;

 	   if (isNaN(lat) || isNaN(lon)) {
	   	 alert("Latitude and Longitude must be numeric");
	      } else if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
	      alert("Latitude or Longitude are invalid");
		  }
	   else
	   {
		updateMap(lat,lon);
		convertedLatLon=convertLatLonToDegrees (lat,lon)

   		// set form fields
		if (convertedLatLon.LonDirection=='W') {$('lon_direction').selectedIndex=1;} else {$('lon_direction').selectedIndex=0;}
		if (convertedLatLon.LatDirection=='S') {$('lat_direction').selectedIndex=1;} else {$('lat_direction').selectedIndex=0;}
  
		$('lat_d').value=convertedLatLon.LatDeg;
		$('lat_m').value=convertedLatLon.LatMin;
		$('lat_s').value=convertedLatLon.LatSec;

		$('lon_d').value=convertedLatLon.LonDeg;
		$('lon_m').value=convertedLatLon.LonMin;
		$('lon_s').value=convertedLatLon.LonSec;

		}
		
	}

	function updateLatLonDecimal() {
	    
	// go from deg, min, sec to decimal

	// Retrieve Lat and Lon information
    var LatDeg = $('lat_d').value;
    var LatMin = $('lat_m').value;
    var LatSec = $('lat_s').value;
    var LonDeg = $('lon_d').value;
    var LonMin = $('lon_m').value;
    var LonSec = $('lon_s').value;

    // Assume the value to be zero if the user does not enter value
    if (LatDeg==null)
      LatDeg=0;
    if (LatMin==null) {
      LatMin=0;
    }
    if (LatSec==null) {
      LatSec=0;
    }
    if (LonDeg==null)
      LonDeg=0;
    if (LonMin==null) {
      LonMin=0
    }
    if (LonSec==null){
      LonSec=0;
    }

	 LatDirection = $('lat_direction').options[$('lat_direction').selectedIndex].text
 	 LonDirection = $('lon_direction').options[$('lon_direction').selectedIndex].text
	 
    // Check if any error occurred
    if (isNaN(LatDeg) || isNaN(LonDeg) || isNaN(LatMin) || isNaN(LonMin) || isNaN(LatSec) || isNaN(LonSec)) {
      alert("Latitude and Longitude must be numeric");
    } else if (LatDeg != Math.round(LatDeg) || LonDeg != Math.round(LonDeg) || LatMin != Math.round(LatMin) || LonMin != Math.round(LonMin)) {
      alert("Latitude or Longitude are invalid");
    } else if (LatDeg < 0 || LatDeg > 90 || LonDeg < 0 || LonDeg > 180 || LatMin < 0 || LatMin > 60 || LonMin < 0 || LonMin > 60 || LatSec < 0 || LatSec > 60 || LonSec < 0 || LonSec > 60) {
      alert("Latitude or Longitude are invalid");
	} else if ((LatDirection !="N" && LatDirection !="S") || (LonDirection !="E" && LonDirection !="W")) {
		alert("Latitude or Longitude direction is invalid");
    } else {
    // If no error, then go on

    // Change to absolute value
    LatDeg = Math.abs(LatDeg);
    LonDeg = Math.abs(LonDeg);
    LatMin = Math.abs(LatMin);
    LonMin = Math.abs(LonMin);
    LatSec = Math.abs(LatSec);
    LonSec = Math.abs(LonSec);

    // Convert to Decimal Degrees Representation
    var lat = LatDeg + (LatMin/60) + (LatSec / 60 / 60);
    var lon = LonDeg + (LonMin/60) + (LonSec / 60 / 60);
    if ( lat <= 90 && lon <= 180 && lat >=0 && lon >= 0 )
    {
      // Copy the absolute value to the board
      $('lat_d').value=LatDeg;
      $('lon_d').value=LonDeg;
      $('lat_m').value=LatMin;
      $('lon_m').value=LonMin;
      $('lat_s').value=LatSec;
      $('lon_s').value=LonSec;

      // Rounding off
      lat = (Math.round(lat*1000000)/1000000);
      lon = (Math.round(lon*1000000)/1000000);

	  if (LatDirection == "S") {
	  	lat = 0 - lat
	  }

	  if (LonDirection == "W") {
	  	lon = 0 - lon
	  }
	  
		$('entry_lat').value=lat;
		$('entry_lon').value=lon;
		
		updateMap(lat,lon);
		
	  }
	}
}

function updateMap(lat,lon) {
		map.clearOverlays();
		map.panTo(new GLatLng(lat,lon));
		marker = new GMarker(new GLatLng(lat,lon));
		map.addOverlay(marker);
		if ($('entry_confidence_range') != null) {
			drawCircle(lat,lon,$('entry_confidence_range').value,$('entry_confidence_range_units').options[$('entry_confidence_range_units').selectedIndex].value);
			}
}

function setMapZoom(zoomLevel) {
	map.setZoom(zoomLevel);
}

function changeConfidenceRange() {	
	drawCircle(marker.getPoint().y,marker.getPoint().x,$('entry_confidence_range').value,$('entry_confidence_range_units').options[$('entry_confidence_range_units').selectedIndex].value);
}

function panAndZoom(lat,lon,zoomLevel) {
    map.setZoom(zoomLevel);
	map.panTo(new GLatLng(lat,lon));
}
function drawCircle(lat,lon,range,units) {
	
   if (units != '' && !isNaN(range)) 
   {
	// approximately 69 miles or 111 km in each degree of latitude
	
	try {
	  map.removeOverlay(circleLine);
	}
	catch(err)
	{
		//
	}
		
	distanceOffset=69.;
	if (units=='kilometers') {distanceOffset=111.}
	
	latOffset=range/distanceOffset;
	newLat = Number(lat)+latOffset;
	
	var centerPoint = new GLatLng(lat,lon);
	var radiusPoint = new GLatLng(newLat,lon);

	var normalProj = G_NORMAL_MAP.getProjection();	
	
	var zoom = map.getZoom();
	var centerPt = normalProj.fromLatLngToPixel(centerPoint, zoom);
	var radiusPt = normalProj.fromLatLngToPixel(radiusPoint, zoom);

	var circlePoints = Array();

	with (Math) {
		radius = floor(sqrt(pow((centerPt.x-radiusPt.x),2) + pow((centerPt.y-radiusPt.y),2)));

		for (var a = 0 ; a < 361 ; a+=10 ) {
			var aRad = a*(PI/180);
			var y = centerPt.y + radius * sin(aRad)
			var x = centerPt.x + radius * cos(aRad)
			var p = new GPoint(x,y);
			circlePoints.push(normalProj.fromPixelToLatLng(p, zoom));
		}


		circleLine = new GPolyline(circlePoints,'#00C000',2,1);
		map.addOverlay(circleLine);

	}
  }
			
}



