package com.whothere.whotheremobile;


import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.client.RestTemplate;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import java.util.Locale;

public class MainActivity extends Activity implements View.OnClickListener, View.OnTouchListener,
        View.OnFocusChangeListener{

    // Views
    private ProgressDialog pDialog;
    private EditText dateText,
                     accessCodeText,
                     occupancyText;
    private Spinner classroomsSpinner,
                    buildingsSpinner,
                    timeSpinner;
    private DatePickerDialog datePickerDialog;
    private SimpleDateFormat dateFormatter;
//    private Button submitBtn;

    // Form variables
    private String classroom,
                   accessCode,
                   date,
                   time;
    private int occupancy;

//    final String  BASE_URL = "http://10.0.2.2:8080";
    final String  BASE_URL = "http://csi420-01-vm1.ucd.ie:8080"

    private List<Building> buildings;
    private Building selectedBuilding;
    private Room selectedRoom;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        dateFormatter = new SimpleDateFormat("yyyy-MM-dd", Locale.UK);
        setViews();
        setDateTimeField();
        // Calling async task to get json
        new HttpRequestTask().execute();
    }

    // Setting all views on activity and listeners
    private void setViews(){
        occupancyText = (EditText)findViewById(R.id.occupancy);
        dateText = (EditText) findViewById(R.id.dateText);
        dateText.setTextIsSelectable(true);
        dateText.requestFocus();
        accessCodeText = (EditText) findViewById(R.id.access_code);
        buildingsSpinner = (Spinner) findViewById(R.id.buildings_spinner);

        Button plusBtn = (Button) findViewById(R.id.plus_btn);
        Button minusBtn = (Button) findViewById(R.id.minus_btn);
        Button submitBtn = (Button) findViewById(R.id.submit_btn);

        // Set default value to classroom spinner
        List<String> classroomTitle =  Collections.singletonList(getString(R.string.classrooms_spinner_title));
        classroomsSpinner = (Spinner) findViewById(R.id.classrooms_spinner);
        ArrayAdapter<String> classroomsAdapter = new ArrayAdapter<String>(MainActivity.this,
                android.R.layout.simple_spinner_item, classroomTitle);
        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        classroomsSpinner.setAdapter(classroomsAdapter);

        // Set values for time spinner
        String[] time = new String[]{getString(R.string.select_time),"8","9","10","11","12","13","14","15","16","17","18"};
        timeSpinner = (Spinner) findViewById(R.id.time_spinner);
        ArrayAdapter<String> timeAdapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, time);
        timeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        timeSpinner.setAdapter(timeAdapter);

        buildingsSpinner.setOnTouchListener(this);
        classroomsSpinner.setOnTouchListener(this);
        timeSpinner.setOnTouchListener(this);
        plusBtn.setOnClickListener(this);
        minusBtn.setOnClickListener(this);

        occupancyText.setOnFocusChangeListener(this);
        accessCodeText.setOnFocusChangeListener(this);

        // Listener for Button "POST"
        submitBtn.setOnClickListener(this);
    }

    @Override
    public void onFocusChange(View v, boolean hasFocus) {
        if(!hasFocus){
            InputMethodManager inputManager = (InputMethodManager)getApplicationContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            inputManager.hideSoftInputFromWindow(occupancyText.getWindowToken(), 0);
            inputManager.hideSoftInputFromWindow(accessCodeText.getWindowToken(), 0);
        }
    }

    @Override
    public void onClick(View view) {
        int occupancyValue = Integer.parseInt(occupancyText.getText().toString());

        switch(view.getId()){
            case R.id.dateText:
                datePickerDialog.show();
                break;
            case R.id.submit_btn:
                getFormValues();
                if(!validateData()) {
                    Toast.makeText(getBaseContext(), "Enter some data!", Toast.LENGTH_LONG).show();
                }else{
                    // Calling async task to get json
                    formatTime();
                    new HttpPostTask().execute();
                }
                break;
            case R.id.plus_btn:
                int increasedValue = occupancyValue + 1;
                occupancyText.setText(Integer.toString(increasedValue));
                break;
            case R.id.minus_btn:

                if (occupancyValue > 0) {
                    int decreasedValue = occupancyValue - 1;
                    occupancyText.setText(new Integer(decreasedValue).toString());
                }
                break;
        }
    }

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        InputMethodManager inputManager = (InputMethodManager)getApplicationContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        inputManager.hideSoftInputFromWindow(occupancyText.getWindowToken(), 0);
        inputManager.hideSoftInputFromWindow(accessCodeText.getWindowToken(), 0);
        return false;
    }

    // Setting date picker window
    private void setDateTimeField() {
        dateText.setOnClickListener(this);

        Calendar newCalendar = Calendar.getInstance();
        datePickerDialog = new DatePickerDialog(this, new DatePickerDialog.OnDateSetListener() {
            public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
                Calendar newDate = Calendar.getInstance();
                newDate.set(year, monthOfYear, dayOfMonth);
                dateText.setText(dateFormatter.format(newDate.getTime()));
            }
        },newCalendar.get(Calendar.YEAR), newCalendar.get(Calendar.MONTH), newCalendar.get(Calendar.DAY_OF_MONTH));
    }

    private void getFormValues(){
        accessCode = accessCodeText.getText().toString();
        classroom = classroomsSpinner.getSelectedItem().toString();
        date = dateText.getText().toString();
        time = timeSpinner.getSelectedItem().toString();
        occupancy = Integer.decode(occupancyText.getText().toString());
    }

    private Boolean validateData(){
        if(accessCode.equals("")) {
            Log.e("ACCESS CODE", "null");
            return false;
        }
        if(classroom.trim().equals(getString(R.string.classrooms_spinner_title))) {
            Log.e("CLASSROOM", "null");
            return false;
        }
        if(date.equals(getString(R.string.select_date))) {
            Log.e("DATE", "null");
            return false;
        }
        if(time.equals(getString(R.string.select_time))) {
            Log.e("TIME", "null");
            return false;
        }else
            return true;
    }

    private void formatTime(){
        time = timeSpinner.getSelectedItem().toString() + ":00:00";
        if(Integer.parseInt(timeSpinner.getSelectedItem().toString()) < 10)
            date = "0" + date;
    }

    private class HttpRequestTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();

            // Show progress dialog
            pDialog = new ProgressDialog(MainActivity.this);
            pDialog.setMessage("Please wait...");
            pDialog.setCancelable(false);
            pDialog.show();
        }

        @Override
        protected Void doInBackground(Void... params) {
            buildings = new ArrayList<Building>();
            try {
                final String url = BASE_URL + "/api/table?request=Room";
                RestTemplate restTemplate = new RestTemplate();
                restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());
                Room[] rooms = restTemplate.getForObject(url, Room[].class);
                for(Room room : rooms){
                    Building tempBuilding = new Building(room.getBuilding());
                    Boolean isFound = false;

                    for(Building building: buildings){

                        if(building.getName().equalsIgnoreCase(room.getBuilding())){
                            tempBuilding = building;
                            isFound = true;
                            break;
                        }
                    }
                    tempBuilding.addRoom(room);
                    if (!isFound) {
                        buildings.add(tempBuilding);
                    }
                }
                return null;
            } catch (Exception e) {
                Log.e("MainActivity", e.getMessage(), e);
            }

            return null;
        }

        @Override
        protected void onPostExecute(Void result){
            // Dismiss the progress dialog
            if (pDialog.isShowing())
                pDialog.dismiss();

            List<String> buildingNames = new ArrayList<String>();
            buildingNames.add(0, getString(R.string.buildings_spinner_title));

            for(Building building : buildings){
                buildingNames.add(building.getName());
            }

            ArrayAdapter<String> buildingsAdapter = new ArrayAdapter<String>(MainActivity.this,
                    android.R.layout.simple_spinner_item, buildingNames);
            buildingsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            buildingsSpinner.setAdapter(buildingsAdapter);

            buildingsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    if (position > 0) {
                        ArrayList<String> roomNames = new ArrayList<String>();
                        roomNames.add(0, getString(R.string.classrooms_spinner_title));
                        for(Building building : buildings){
                            if(building.getName().equalsIgnoreCase(parent.getItemAtPosition(position).toString())){
                                selectedBuilding = building;
                                for(Room room : building.getRooms()){
                                    roomNames.add(room.getRoomNo());
                                }
                            }
                        }

                        ArrayAdapter<String> classroomsAdapter = new ArrayAdapter<String>(MainActivity.this,
                                android.R.layout.simple_spinner_item, roomNames);
                        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                        classroomsSpinner.setAdapter(classroomsAdapter);
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> arg0) {
                    // TODO Auto-generated method stub
                }
            });

            classroomsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    if (position > 0) {
                        ArrayList<String> roomNames = new ArrayList<String>();
                        for(Room room : selectedBuilding.getRooms()){
                            if(room.getRoomNo().equalsIgnoreCase(parent.getItemAtPosition(position).toString())){
                                selectedRoom = room;
                            }
                        }
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> arg0) {
                    // TODO Auto-generated method stub
                }
            });
        }
    }

    private class HttpPostTask extends AsyncTask<Void, Void, Void> {
        @Override
        protected Void doInBackground(Void... params) {
            try {
                final String url = BASE_URL + "/post/groundtruth";

//                GroundTruthData groundTruthData = new GroundTruthData(1, 80, "B002", "2016-08-06", "10:00:00", 70);

                Log.e("GroundTruth", "ROOM ID " + selectedRoom.getRoomId() + "\nCAPACITY: " +  selectedRoom.getCapacity()
                        + "\nROOM NO: " + selectedRoom.getRoomNo() + "\nDATE: " + date
                        + "\nTIME: " + time + "\nOCCUPANCY: " + occupancy);
                GroundTruthData groundTruthData = new GroundTruthData(selectedRoom.getRoomId(), selectedRoom.getCapacity(),
                        selectedRoom.getRoomNo(), date, time, occupancy);

                // Set the Content-Type header
                HttpHeaders requestHeaders = new HttpHeaders();
                requestHeaders.setContentType(new MediaType("application","json"));
                HttpEntity<GroundTruthData> requestEntity = new HttpEntity<GroundTruthData>(groundTruthData, requestHeaders);

                RestTemplate restTemplate = new RestTemplate();
                restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());
                restTemplate.getMessageConverters().add(new StringHttpMessageConverter());
                ResponseEntity<String> responseEntity = restTemplate.exchange(url, HttpMethod.POST, requestEntity, String.class);

                HttpStatus statusCode = responseEntity.getStatusCode();
                Log.e("code: ", statusCode.toString());
                if(statusCode.value() == 200){
                    Log.e("code: ", statusCode.value() + "Thank you");
                    Intent intent = new Intent(MainActivity.this, SuccessActivity.class);
                    startActivity(intent);
                }else{
                    Log.e("code: ", statusCode.value() + "Error");
                    Intent intent = new Intent(MainActivity.this, ErrorActivity.class);
                    startActivity(intent);
                }

                return null;
            } catch (Exception e) {}

            return null;
        }
    }
}
