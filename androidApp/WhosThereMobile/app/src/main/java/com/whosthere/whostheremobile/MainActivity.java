package com.whosthere.whostheremobile;

import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

public class MainActivity extends AppCompatActivity implements View.OnClickListener, View.OnTouchListener {

    private ProgressDialog pDialog;
    private EditText dateText;
    private EditText accessCode;
    private EditText occupancyText;
    private Spinner classroomsSpinner;
    private Spinner buildingsSpinner;
    private DatePickerDialog datePickerDialog;
    private SimpleDateFormat dateFormatter;

    // JSON Node names
    private static final String TAG_BUILDING = "Building";
    private static final String TAG_ROOM_NO = "Room_no";

    JSONArray classrooms = null;
    JSONObject classObj = null;
    ArrayList<HashMap<String, String>> classroomList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        dateFormatter = new SimpleDateFormat("dd-MM-yyyy", Locale.UK);
        classroomList = new ArrayList<HashMap<String, String>>();

        setViews();
        setDateTimeField();

        // Calling async task to get json
        new GetClassrooms().execute();
    }

    // Setting all views on activity and listeners
    private void setViews(){
        occupancyText = (EditText)findViewById(R.id.occupancy);
        dateText = (EditText) findViewById(R.id.dateText);
        dateText.requestFocus();
        accessCode = (EditText) findViewById(R.id.access_code);

        buildingsSpinner = (Spinner) findViewById(R.id.buildings_spinner);

        Button plusBtn = (Button) findViewById(R.id.plus_btn);
        Button minusBtn = (Button) findViewById(R.id.minus_btn);

        // Set default value to classroom spinner
        List<String> classroomTitle =  Collections.singletonList(getString(R.string.classrooms_spinner_title));
        classroomsSpinner = (Spinner) findViewById(R.id.classrooms_spinner);
        ArrayAdapter<String> classroomsAdapter = new ArrayAdapter<String>(MainActivity.this,
                android.R.layout.simple_spinner_item, classroomTitle);
        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        classroomsSpinner.setAdapter(classroomsAdapter);

        // Values for time spinner
        List<String> time = Arrays.asList("Select a time", "8.00", "9.00", "10.00", "11.00", "12.00", "13.00",
                "14.00", "15.00", "16.00", "17.00", "18.00");

        // Set values to time spinner
        Spinner timeSpinner = (Spinner) findViewById(R.id.time_spinner);
        ArrayAdapter<String> timeAdapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_spinner_item, time);
        timeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        timeSpinner.setAdapter(timeAdapter);

        buildingsSpinner.setOnTouchListener(this);
        classroomsSpinner.setOnTouchListener(this);
        timeSpinner.setOnTouchListener(this);

        // Listener for plusBtn - increases value of occupancy textfield by 1
        if(plusBtn != null) {
            plusBtn.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    int a = Integer.parseInt(occupancyText.getText().toString());
                    int b = a + 1;
                    occupancyText.setText(Integer.toString(b));
                }
            });
        }
        // Listener for minusBtn - decreases value of occupancy textfield by 1 if value greater than 0
        if(minusBtn != null) {
            minusBtn.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    int a = Integer.parseInt(occupancyText.getText().toString());
                    if (a > 0) {
                        int b = a - 1;
                        occupancyText.setText(new Integer(b).toString());
                    }
                }
            });
        }
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

    // On click listener for date field, opens date picker window
    @Override
    public void onClick(View view){
            if(view == dateText) {
                datePickerDialog.show();
            }
    }

    // On touch listener, closes virtual keyboard
    @Override
    public boolean onTouch(View v, MotionEvent event) {
        InputMethodManager inputManager =(InputMethodManager)getApplicationContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        inputManager.hideSoftInputFromWindow(occupancyText.getWindowToken(), 0);
        inputManager.hideSoftInputFromWindow(accessCode.getWindowToken(), 0);
        return false;
    }

    // Async task class to get json with HTTP call
    private class GetClassrooms extends AsyncTask<Void, Void, Void> {

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
        protected Void doInBackground(Void... arg0) {
            // URL to get classroom JSON
            String url = "http://csi420-01-vm1.ucd.ie:8080/api/table?request=Room";

            // Creating service handler class instance
            ServiceHandler sh = new ServiceHandler();

            // Make a request to url
            String jsonStr = sh.makeServiceCall(url, ServiceHandler.GET);

            if (jsonStr != null) {
                try {
                    // parse json string to array
                    classrooms = new JSONArray(jsonStr);

                    // looping through classrooms
                    for (int i = 0; i < classrooms.length(); i++) {
                        JSONObject c = classrooms.getJSONObject(i);

                        String building = c.getString(TAG_BUILDING);
                        String roomNo = c.getString(TAG_ROOM_NO);

                        // create hashmap for single entry
                        HashMap<String, String> entry = new HashMap<String, String>();

                        // adding each child node to HashMap key => value
                        entry.put(TAG_BUILDING, building);
                        entry.put(TAG_ROOM_NO, roomNo);

                        // adding contact to contact list
                        classroomList.add(entry);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                Log.e("ServiceHandler", "Couldn't get any data from the url");
            }
            return null;
        }

        @Override
        protected void onPostExecute(Void result) {
            super.onPostExecute(result);

            // Dismiss the progress dialog
            if (pDialog.isShowing())
                pDialog.dismiss();

            ArrayList<String> buildings = new ArrayList<String>();
            buildings.add(0, getString(R.string.buildings_spinner_title));
            String current = "";

            for(int i = 0; i < classroomList.size(); i++) {
                String c = classroomList.get(i).get(TAG_BUILDING);
                if (!c.equalsIgnoreCase(current)) {
                    buildings.add(c);
                }
                current = c;
            }


            ArrayAdapter<String> buildingsAdapter = new ArrayAdapter<String>(MainActivity.this,
                    android.R.layout.simple_spinner_item, buildings);
            buildingsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            buildingsSpinner.setAdapter(buildingsAdapter);

            buildingsSpinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    if (position > 0) {
                        ArrayList<String> classrooms = new ArrayList<String>();
                        classrooms.add(0, getString(R.string.classrooms_spinner_title));
                        for (int i = 0; i < classroomList.size(); i++) {
                            if (classroomList.get(i).get(TAG_BUILDING).equalsIgnoreCase(parent.getItemAtPosition(position).toString()))
                                classrooms.add(classroomList.get(i).get(TAG_ROOM_NO));
                        }

//                        Spinner classroomsSpinner = (Spinner) findViewById(R.id.classrooms_spinner);
                        ArrayAdapter<String> classroomsAdapter = new ArrayAdapter<String>(MainActivity.this,
                                android.R.layout.simple_spinner_item, classrooms);
                        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                        classroomsSpinner.setAdapter(classroomsAdapter);
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> arg0) {
                    // TODO Auto-generated method stub
                }
            });
        }
    }
}
