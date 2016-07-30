package com.whosthere.whostheremobile;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

public class MainActivity extends AppCompatActivity implements OnItemSelectedListener{

    private ProgressDialog pDialog;

    // URL to get contacts JSON
    private static String url = "http://csi420-01-vm1.ucd.ie:8080/api/table?request=Room";

    // JSON Node names
    private static final String TAG_BUILDING = "Building";
    private static final String TAG_CAPACITY = "Capacity";
    private static final String TAG_ROOM_ID = "Room_id";
    private static final String TAG_ROOM_NO = "Room_no";

    // contacts JSONArray
    JSONArray classrooms = null;

    // Hashmap for ListView
    ArrayList<HashMap<String, String>> classroomList;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        classroomList = new ArrayList<HashMap<String, String>>();

        // Calling async task to get json
        new GetClassrooms().execute();

//        Spinner buildingsSpinner = (Spinner) findViewById(R.id.buildings_spinner);
//        ArrayAdapter<CharSequence> buildingsAdapter = ArrayAdapter.createFromResource(this,
//                R.array.buildings_array, android.R.layout.simple_spinner_item);
//        buildingsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
//        buildingsSpinner.setAdapter(buildingsAdapter);

        Spinner classroomsSpinner = (Spinner) findViewById(R.id.classrooms_spinner);
        ArrayAdapter<CharSequence> classroomsAdapter = ArrayAdapter.createFromResource(this,
                R.array.classrooms_array, android.R.layout.simple_spinner_item);
        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        classroomsSpinner.setAdapter(classroomsAdapter);

        final EditText ed=(EditText)findViewById(R.id.occupancy);
        Button b1=(Button)findViewById(R.id.plus_btn);
        Button b2=(Button)findViewById(R.id.minus_btn);

        b1.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // TODO Auto-generated method stub
                int a=Integer.parseInt(ed.getText().toString());
                int b=a+1;
                ed.setText(new Integer(b).toString());
            }
        });

        b2.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                int a = Integer.parseInt(ed.getText().toString());
                if(a > 0) {
                    int b = a - 1;
                    ed.setText(new Integer(b).toString());
                }
            }
        });
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        String item = parent.getItemAtPosition(position).toString();
        Toast.makeText(parent.getContext(), "Selected: " + item, Toast.LENGTH_LONG).show();
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
        // Another interface callback
    }

    /**
     * Async task class to get json by making HTTP call
     * */
    private class GetClassrooms extends AsyncTask<Void, Void, Void> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            // Showing progress dialog
            pDialog = new ProgressDialog(MainActivity.this);
            pDialog.setMessage("Please wait...");
            pDialog.setCancelable(false);
            pDialog.show();
        }

        @Override
        protected Void doInBackground(Void... arg0) {
            // Creating service handler class instance
            ServiceHandler sh = new ServiceHandler();

            // Making a request to url and getting response
            String jsonStr = sh.makeServiceCall(url, ServiceHandler.GET);

            Log.d("Response: ", "> " + jsonStr);

            if (jsonStr != null) {
                try {
//                    JSONObject jsonObj = new JSONObject(jsonStr);

                    // Getting JSON Array node
                    classrooms = new JSONArray(jsonStr);

                    // looping through All Contacts
                    for (int i = 0; i < classrooms.length(); i++) {
//                        JSONObject c = classrooms.getJSONObject(i);

                        String building = classrooms.getJSONObject(i).getString(TAG_BUILDING);
                        String capacity = classrooms.getJSONObject(i).getString(TAG_CAPACITY);
                        String roomId = classrooms.getJSONObject(i).getString(TAG_ROOM_ID);
                        String roomNo = classrooms.getJSONObject(i).getString(TAG_ROOM_NO);

                        // tmp hashmap for single contact
                        HashMap<String, String> contact = new HashMap<String, String>();

                        // adding each child node to HashMap key => value
                        contact.put(TAG_BUILDING, building);
                        contact.put(TAG_CAPACITY, capacity);
                        contact.put(TAG_ROOM_ID, roomId);
                        contact.put(TAG_ROOM_NO, roomNo);

                        // adding contact to contact list
                        classroomList.add(contact);
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
            String current = "";

            for(int i = 0; i < classroomList.size(); i++) {
                Iterator it = classroomList.get(i).entrySet().iterator();
                while (it.hasNext()) {
                    Map.Entry pair = (Map.Entry) it.next();

                    if(pair.getKey().toString().equalsIgnoreCase("Building")){
                        if(!pair.getValue().toString().equalsIgnoreCase(current)){
                            Log.i("IN IF", "Iteration" + i + " " + pair.getValue().toString() + " " + current);
                            buildings.add(pair.getValue().toString());
                        }
                        current = pair.getValue().toString();
//                        Log.i("CURRENT", current);
                    }
//                    Log.i("ITERATION",pair.getKey() + " = " + pair.getValue());
                    it.remove(); // avoids a ConcurrentModificationException
                }
            }

            for (int j = 0; j < buildings.size(); j++){
                Log.i("BUILDING LIST", buildings.get(j) + " SIZE " + buildings.size());
            }
            Spinner buildingsSpinner = (Spinner) findViewById(R.id.buildings_spinner);
            ArrayAdapter<String> buildingsAdapter = new ArrayAdapter<String>(MainActivity.this,
                    android.R.layout.simple_spinner_item, buildings);
            buildingsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            buildingsSpinner.setAdapter(buildingsAdapter);
        }
    }
}
