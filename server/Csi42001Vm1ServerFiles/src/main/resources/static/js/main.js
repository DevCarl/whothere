// Author - Ophélie Alliaume and Conor O'Kelly

//<![CDATA[

// Create map varialbe as undefiend
var geo_map;


function fetchJsonApi () {
    var dataResponse = "";
    var url = '/api/tablesearch?request=Room&key=Building'
    var xmr = new XMLHttpRequest();
    xmr.open("GET", url, false);

    xmr.onreadystatechange = function(oEvent) {
    if (xmr.readyState === 4) {
        if (xmr.status === 200) {
            dataResponse = JSON.parse(xmr.responseText);
            console.log(dataResponse);
        } else {
            console.log("Error", xmr.statusText)
        }
        }
    }
    xmr.send(null);
}

function hey () {
    alert("hi");
}

// Function to call api

 var dataResponse = "";
            var url = '/api/tablesearch?request=Room&key=Building'
            var xmr = new XMLHttpRequest();
            xmr.open("GET", url, false);
            xmr.onreadystatechange = function(oEvent) {
            if (xmr.readyState === 4) {
                if (xmr.status === 200) {
                    dataResponse = JSON.parse(xmr.responseText);
                    console.log(dataResponse);
                    
                } else {
                    console.log("Error", xmr.statusText)
                }
            }
        }
            xmr.send(null);

// Create map and draw rooms on.
function genearteMap () {
    
    // Erase map if one exists
    if (geo_map != undefined) {geo_map.remove();}
    
    // Get form input varialbes
    var floor_no = $('input[name="floor_no"]:checked').val();
    
    
    geo_map = L.map('floor_plan_wrap', {
        crs: L.CRS.Simple,
        zoomControl:false,
        dragging:false,
        minZoom: 0,
        maxZoom: 0
    });
    geo_map.panTo([0, 0]);
    var bounds = [[0, 0], [400, 600]];
    
    geo_map.eachLayer(function (layer) {
        geo_map.removeLayer(layer);
    });
    
    var rooms_ground_floor = [{
        "type": "Feature",
        "properties": {"room": "B002"},
        "geometry": {
            "type": "Polygon",
            "coordinates": [[
                [332,146],
                [333, 5],
                [407, 5],
                [407,146]
            ]]
        }
    },
        {
        "type": "Feature",
        "properties": {"room": "B003"},
        "geometry": {
            "type": "Polygon",
            "coordinates": [[
                [407,146],
                [407, 5],
                [482,3],
                [482,143]
            ]]
        }
    },
          {
            "type": "Feature",
            "properties": {"room": "B004"},
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [482,143],
                    [482,3],
                    [596,2],
                    [597,141]
                ]]
            }
        }
    ]
    
    var rooms_first_floor = [
        {
           "type": "Feature",
            "properties": {"room": "B108"},
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [241, 164],
                    [244, 76],
                    [342, 80],
                    [338, 167]
                ]]
            } 
        },
        {
           "type": "Feature",
            "properties": {"room": "B109"},
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [339, 167],
                    [342, 80],
                    [438, 84],
                    [439, 171]
                ]]
            } 
        },
        {"type": "Feature",
            "properties": {"room": "B106"},
            "geometry": {
                "type": "Polygon",
                "coordinates": [[
                    [439, 171],
                    [438, 3],
                    [594, 3],
                    [597, 176]
                    
                ]]
            } 
        } 
    ]

    
    // Set which map to load and which rooms to set
    
    var testDirectory = "../static/"
    
    var floor_0 = "img/CSI_floor_0.png";
    var floor_1 = "img/CSI_floor_1.png";
    var current_floor;
    
    var current_room_set;
    
    if (floor_no=="ground"){
        current_floor = floor_0;
        current_room_set = rooms_ground_floor;
    }
    else if (floor_no="first"){
        current_floor = floor_1;
        current_room_set = rooms_first_floor;
    }
    
//    console.log(floor_no, current_floor);
    
    var image = L.imageOverlay(current_floor, bounds).addTo(geo_map);
    

    geo_map.fitBounds(bounds);

    L.geoJson(current_room_set, {
        style: function(feature) {
            switch (feature.properties.room) {
                case 'B108': return {color: "red"};
                case 'B004':   return {color: "green"};
            }
        },
        onEachFeature: function (feature, layer) {
            popupOptions = {maxWidth: 200};
            layer.bindPopup("<b>Site name: </b>" + feature.properties.room,popupOptions);
        }
    }).addTo(geo_map);

//                    B002.bindPopup("<div>I am a polygon.<br/>This is a special type of div</div>");   
    

}


//]]>