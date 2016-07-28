package com.whosthere.whostheremobile;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.StatusLine;
import org.apache.http.client.HttpClient;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.client.methods.HttpGet;
import android.util.Log;

public class MainActivity extends AppCompatActivity implements OnItemSelectedListener{

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Spinner buildingsSpinner = (Spinner) findViewById(R.id.buildings_spinner);
        ArrayAdapter<CharSequence> buildingsAdapter = ArrayAdapter.createFromResource(this,
                R.array.buildings_array, android.R.layout.simple_spinner_item);
        buildingsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        buildingsSpinner.setAdapter(buildingsAdapter);

        Spinner classroomsSpinner = (Spinner) findViewById(R.id.classrooms_spinner);
        ArrayAdapter<CharSequence> classroomsAdapter = ArrayAdapter.createFromResource(this,
                R.array.classrooms_array, android.R.layout.simple_spinner_item);
        classroomsAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        classroomsSpinner.setAdapter(classroomsAdapter);

//        TextView tv = (TextView) findViewById(R.id.textview);
//        tv.append("YO:\n" + getJson());


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
}
