// Author - Ophélie Alliaume and Conor O'Kelly

//<![CDATA[

// Create map varialbe as undefiend
var geo_map;
var dataResponse = "";

// Load inital respone to populate drop down menus
var search_url = "http://csi420-01-vm1.ucd.ie:8080/api/data?request=Date&Date=2015/11/13";
load_data_response(search_url);



function hey () {
    alert("hi");
}

// Serach bar funcion

function load_serach() {
    
    var buildling = $('#building').val();
    var room = $('#classroom').val();
    var date = $('#search_date').val();
    
    if (buildling.trim() == "Select a building") {
        alert("Please select a building");
    }
    // Removed as not using room section in seach bar
//    else if (room.trim() == "Select a classroom") {
//        alert("Please select a room");
//    }
    else {
        // Load correct div depending on page
        $('#info_section').css('display','block');
        $('#map').css('display','none');
        $('#main_dynamic_map').css('display','block');
        $('#no_info_error').css('display','none');
        
        // Load new json xmr.open("GET", url, false);
        
        search_date = date.replace('-', "/").replace('-', "/");
        search_url = "http://csi420-01-vm1.ucd.ie:8080/api/data?request=Date&Date=" + search_date;
    
        load_data_response(search_url);
        
        // Generate map
        genearteMap ();
        
    }
    
    
    
    return false;
}


// Function to call api

function load_data_response (url) { 
//    var url = 'http://csi420-01-vm1.ucd.ie:8080/api/data?request=Date&Date=2015/11/11'
    var xmr = new XMLHttpRequest();
    xmr.open("GET", url, false);
    xmr.onreadystatechange = function(oEvent) {
        if (xmr.readyState === 4) {
            if (xmr.status === 200) {
                window.dataResponse = JSON.parse(xmr.responseText);

            } else {
                console.log("Error", xmr.statusText)
            }
        }
    }
    xmr.send(null);

}


// Create map and draw rooms on.
function genearteMap () {
    
    // Erase map if one exists
    if (geo_map != undefined) {geo_map.remove();}
    
    //
    // Get form input varialbes
    var floor_no = $('input[name="floor_no"]:checked').val();
    var current_time = $('#slider_value').val();
    // Check if time is 9:00:00
    if (current_time=="9:00:00") {
        current_time = "09:00:00";
    }
    var current_date =  $('#search_date').val().trim();
    console.log(current_date);
    console.log(dataResponse);
    
    
    geo_map = L.map('floor_plan_wrap', {
        crs: L.CRS.Simple,
        zoomControl:false,
//        dragging:false,
        minZoom: 0,
        maxZoom: 0
    });
    geo_map.panTo([0, 0]);
    var bounds = [[0, 0], [400, 600]];
    
    geo_map.eachLayer(function (layer) {
        geo_map.removeLayer(layer);
    });
    
    var rooms_ground_floor = [
        {"type": "Feature",
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
        {"type": "Feature",
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
          {"type": "Feature",
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
        {"type": "Feature",
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
        {"type": "Feature",
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
    
    // Combine external json and geojson files together
    rooms_ground_floor[0].apiData = dataResponse.Room_no.B002;
    rooms_ground_floor[1].apiData = dataResponse.Room_no.B003;
    rooms_ground_floor[2].apiData = dataResponse.Room_no.B004;


    
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
        // Set color of room
        style: function(feature) {

            if (floor_no=="ground") {
                // Logistic regression results
                var log_reg = (feature.apiData.Date[current_date].Timeslot[current_time].Logistic_occupancy).trim();
                switch (log_reg){
                        case "Low" : return {color: "#B22222"};
                        case "Mid_Low" : return {color: "#FAB117"};
                        case "Mid_High" : return {color: "#FAB117"};
                        case "High" : return {color: "#228B22"};
                }
                
                
//                // Percentage of room full
//                var capacity = feature.apiData.Capacity;
//                var people_estimate = feature.apiData.Date[current_date].Timeslot[current_time].People_estimate;
//                var percentage_full = people_estimate / capacity;
////                console.log(current_time);
////                console.log(percentage_full, people_estimate, capacity);
//                
//                if (percentage_full <= 0.3) {
//                    return {color: "#B22222"};
//                }
//                else if (0.3 < percentage_full && percentage_full <= 0.6) {
//                    return {color: "#FAB117"};
//                }
//                else {
//                    return {color: "#228B22"};
//                }
            }
            else if (floor_no="first") {
                switch (feature.properties.room) {
                    case 'B109': return {color: "gery"};
                    case 'B108':   return {color: "gery"};
                    case 'B106':   return {color: "gery"};
                }
            }
        },
        onEachFeature: function (feature, layer) {
            popupOptions = {maxWidth: 330};
            
            if (floor_no=="ground") {
//                console.log(feature.apiData.Date[current_date].Timeslot[current_time]);
                layer.bindPopup("<p class='center_text'><b> Room name: </b>" + feature.properties.room + "</p>" +
                                "<p> "
                                + "<b> Room name</b>: " + feature.apiData.Building 
                                + "<br/> <b>Campus</b>: " + feature.apiData.Campus 
                                + "<br/> <b>Building capacity</b>:"  + feature.apiData.Capacity 
                                + "<br/> <b>Plug_friendly</b>: " + feature.apiData.Plug_friendly 
                                + "<br/> <b>No_expected_students</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].No_expected_students 
                                + "<br/> <b>Class_went_ahead</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Class_went_ahead 
                                + "<br/> <b>Module</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Module.Module_code
                                + "<br/> <b>Facilty</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Module.Facilty
                                + "<br/> <b>Undergrad</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Module.Undergrad
                                + "<br/> <b>Course Level</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Module.Course_level
                                + "<br/> <b>People_estimate</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].People_estimate 
                                + "<br/> <b>Min_people_estimate</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Min_people_estimate 
                                + "<br/> <b>Max_people_estimate</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Max_people_estimate 
                                + "<br/> <b>Logistic_occupancy</b>: " + feature.apiData.Date[current_date].Timeslot[current_time].Logistic_occupancy
                                + "</p>", popupOptions);
            }
            else if (floor_no=="first") {
                layer.bindPopup("<p class='center_text'><b> Room name: </b>" + feature.properties.room + 
                                "<br/> This room currently has no data. </p>", popupOptions);    
            }
            
            
        }
    }).addTo(geo_map);

//                    B002.bindPopup("<div>I am a polygon.<br/>This is a special type of div</div>");   
    

}


//]]>