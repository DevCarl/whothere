//<![CDATA[


var geo_map;
console.log(geo_map);


function genearteMap () {
    
    if (geo_map != undefined) {geo_map.remove();}
    
    geo_map = L.map('floor_plan_wrap', {
        crs: L.CRS.Simple,
        zoomControl:false,
        dragging:false,
    });
    geo_map.panTo([0, 0]);
    var bounds = [[0, 0], [400, 600]];
    
    geo_map.eachLayer(function (layer) {
        geo_map.removeLayer(layer);
    });

    var image = L.imageOverlay('../static/img/CSI_floor_0.png', bounds).addTo(geo_map);

    geo_map.fitBounds(bounds);

    var rooms = [{
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
    },           
                 ]
//                    
//                    var number = prompt("give a number");
//                    if (number == "1") {alert("yes")};

    L.geoJson(rooms, {
        style: function(feature) {
            switch (feature.properties.room) {
                case 'B003': return {color: "red"};
                case 'B004':   return {color: "green"};
            }
        }
        }).addTo(geo_map);

//                    B002.bindPopup("<div>I am a polygon.<br/>This is a special type of div</div>");   
    

}

//]]>