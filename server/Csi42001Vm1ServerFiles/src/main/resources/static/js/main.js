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
    else if (date == "2015-11-07" || date == "2015-11-08") {
        alert("Pleaes select a date that is not the weekend");
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
        // Generate Charts
        generateCharts ();
        
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
    
    // Get form input varialbes
    var floor_no = $('input[name="floor_no"]:checked').val();
    var current_time = $('#slider_value').val();
    // Check if time is 9:00:00
    if (current_time=="9:00:00") {
        current_time = "09:00:00";
    }
    var current_date =  $('#search_date').val().trim();
//    console.log(current_date);
//    console.log(dataResponse);
    
    // Hide one of the chart divs
    if (floor_no == "ground") {
        $('.ground_floor_charts').css('display','block');
        $('.room_charts_section').css('display','block');
        $('.first_floor_charts').css('display','none');
    }
    else {
        $('.ground_floor_charts').css('display','none');
        $('.room_charts_section').css('display','none');
        $('.first_floor_charts').css('display','block');
    }
    
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
                        case "Low" : return {color: "#d50f25"};
                        case "Mid_Low" : return {color: "#eeb211"};
                        case "Mid_High" : return {color: "#009925"};
                        case "High" : return {color: "#3369e8"};
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


// Generate charts based on room

function generateCharts () {
    
    // Testing section
    generateCalanderData();
    
    // Clear current charts
    google.charts.clearChart;
    
    // Loads charts => callback
    google.charts.setOnLoadCallback(drawTimelineChart);
    google.charts.setOnLoadCallback(drawLinesChart);
    google.charts.setOnLoadCallback(drawCalanderChart);
    
    // Function to draw the charts
    function drawTimelineChart() {
        var bar_chart_data = generateBarChartData();
        
        var container = document.getElementById('timeline');
        var chart = new google.visualization.Timeline(container);
        var dataTable = new google.visualization.DataTable();

        dataTable.addColumn({ type: 'string', id: 'Occupancy level' });
        dataTable.addColumn({ type: 'date', id: 'Start' });
        dataTable.addColumn({ type: 'date', id: 'End' });
        dataTable.addRows(bar_chart_data);
        chart.draw(dataTable);
    }
    
    // Draw interval chart
    function drawLinesChart() {
        
        var linesChartData = generateLinesChartData();
        var data = new google.visualization.DataTable();
        data.addColumn('number', 'x');
        data.addColumn('number', 'Estimated occupancy');
        data.addColumn({id:'i1', type:'number', role:'interval'});
        data.addColumn({id:'i2', type:'number', role:'interval'});
        data.addRows(linesChartData);

        var options = {
            title:'Daily occupancy',
            curveType:'function',
            series: [{'color': '#F1CA3A'}],
            intervals: { 'style':'area',
                         'color': '#fdde9b'},
            legend: 'top',
            hAxis: {title: 'Time',       
                    format: '0',                     
            },
            vAxis: {title: 'Number of people'}
        };
  
        var chart_lines = new google.visualization.LineChart(document.getElementById('chart_lines'));
        chart_lines.draw(data, options);
    }
    
    function drawCalanderChart() {
        
        var CalanderData = generateCalanderData();
        
        var dataTable = new google.visualization.DataTable();
        dataTable.addColumn({ type: 'date', id: 'Date' });
        dataTable.addColumn({ type: 'number', id: 'Occupancy' });
        dataTable.addRows(CalanderData);

        var chart = new google.visualization.Calendar(document.getElementById('calendar_basic'));

        var options = {
            title: "Daily Average Occupancy",
            height: 200,
        };

        chart.draw(dataTable, options);
    }
}

function generateBarChartData () {
    
    // Get chosen room and day
    var select_room = $('input[name="room_no"]:checked').val();
    var current_date =  $('#search_date').val().trim();
    var barCharDataArray = [];
    
    for(var date in dataResponse.Room_no[select_room].Date){
        var year = date.substring(0,4);
        var month = date.substring(5, 7);
        var day = date.substring(8);

        for(var timeSlot in dataResponse.Room_no[select_room].Date[current_date].Timeslot){
            var students = dataResponse.Room_no[select_room].Date[date].Timeslot[timeSlot].Logistic_occupancy;

            var timeSlotStart = parseInt(timeSlot.substring(0,2));
            var timeSlotEnd = timeSlotStart + 1;

            var startDate = new Date(year, month, day, timeSlotStart);
            var endDate = new Date(year, month, day, timeSlotEnd);

//            console.log("Time: " + timeSlot + " start "+ timeSlotStart + " end " + timeSlotEnd);
            barCharDataArray.push([students, startDate, endDate]);
        }
    }
    
//    for (var i=0; i<barCharDataArray.length; i++) {
////        console.log(barCharDataArray[i][0]);
//        if (barCharDataArray[i][0].trim() == "Mid_High" || barCharDataArray[i][0].trim() == "Mid_Low") {
//            barCharDataArray[i][0] = "Mid";
//        }
//    }
    
    return barCharDataArray;
}

function generateLinesChartData () {
    
    // Get variables
    var select_room = $('input[name="room_no"]:checked').val();
    var current_date =  $('#search_date').val().trim();
    var intervalDataArray = [];
    
    var maxArray = [];
    var minArray = [];
    var estimate = [];
    
    for(var timeSlot in dataResponse.Room_no[select_room].Date[current_date].Timeslot){
        
        intervalDataArray.push([parseInt(timeSlot.substring(0,2)),
                        dataResponse.Room_no[select_room].Date[current_date].Timeslot[timeSlot].People_estimate,
                        dataResponse.Room_no[select_room].Date[current_date].Timeslot[timeSlot].Max_people_estimate,
                        dataResponse.Room_no[select_room].Date[current_date].Timeslot[timeSlot].Min_people_estimate]);
    }
    
    intervalDataArray.sort(sortFunction);

    function sortFunction(a, b) {
        if (a[0] === b[0]) {
            return 0;
        }
        else {
            return (a[0] < b[0]) ? -1 : 1;
        }
    }
    
    return intervalDataArray;
}

function generateCalanderData () {
    
    var select_room = $('input[name="room_no"]:checked').val();
    var current_date =  $('#search_date').val().trim();
    
    var CalanderApi = "";
    var currentUrl = 'http://csi420-01-vm1.ucd.ie/api/data?request=Room_no&Room_no='+ select_room
//    console.log(currentUrl);
    
    // Get multi week data for room
    var xmr = new XMLHttpRequest();
    xmr.open("GET", currentUrl, false);
    
    xmr.onreadystatechange = function(oEvent) {
//        console.log("Ready state: " + xmr.readyState);
        if (xmr.readyState === 4) {
//            console.log("status: " + xmr.status);   
            if (xmr.status === 200) {
                CalanderApi = JSON.parse(xmr.responseText);

            } else {
                console.log("Error", xmr.statusText)
            }
        }
    }    
    xmr.send(null);
    
    var CalanderdataArray = [];

    for(var date in CalanderApi.Room_no[select_room].Date){
        var i = 0;
        var sum = 0;
        for(var timeSlot in CalanderApi.Room_no[select_room].Date[date].Timeslot){
            sum += CalanderApi.Room_no[select_room].Date[date].Timeslot[timeSlot].People_estimate;
                i++;
        }
        var year = parseInt(date.substring(0,4));
        var month = parseInt(date.substring(5,7)) - 1;
        var day = parseInt(date.substring(8));
//        console.log("Year: " + year + "\nMonth: " + month + "\nDay: " + day)
        var formattedDate = new Date(year, month, day);
        var avgOccupancy = parseInt(sum / i);
        CalanderdataArray.push([formattedDate, avgOccupancy]);
    }
    
    
    return CalanderdataArray;
}

//]]>