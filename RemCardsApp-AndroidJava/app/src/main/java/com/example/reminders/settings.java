package com.example.reminders;

import android.content.Intent;
import android.content.SharedPreferences;
import android.database.sqlite.SQLiteDatabase;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;

import com.google.android.material.snackbar.Snackbar;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.SortedMap;

import maes.tech.intentanim.CustomIntent;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static android.widget.Toast.LENGTH_SHORT;

public class settings extends AppCompatActivity {
    EditText JSONfield;
    Button impJSON, clearData, toggleDarkMode, saveSort, log, editProfile;
    DatabaseHelper myDb;
    TextView name;

    private FirebaseUser user;
    private DatabaseReference reference;
    private String userID;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.settings);
        JSONfield = findViewById(R.id.frm_ison);
        impJSON = findViewById(R.id.btn_importJSON);
        clearData = findViewById(R.id.btn_clearData);
        myDb = new DatabaseHelper(this);
        toggleDarkMode = findViewById(R.id.btn_darkMode);
        toggleDarkMode.setText("Toggle on/off");
        saveSort = findViewById(R.id.btn_savesort);
        log = findViewById(R.id.settings_login);
        name = findViewById(R.id.userinfo);
        editProfile = findViewById(R.id.settings_credentials);
        final Spinner spinner = (Spinner) findViewById(R.id.setSort);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.sort, R.layout.spinner1_textview);
        adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(adapter);
        SharedPreferences sharedPreferences = getSharedPreferences("DarkMode", 0);
        final SharedPreferences.Editor editor = sharedPreferences.edit();
        final boolean isDarkModeOn = sharedPreferences.getBoolean("isDarkModeOn", false);


        user = FirebaseAuth.getInstance().getCurrentUser();
        reference = FirebaseDatabase.getInstance().getReference("Users");
        userID = user.getUid();

        reference.child(userID).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                User userProfile = dataSnapshot.getValue(User.class);
                if(userProfile!=null){
                    String fullname = userProfile.nameUser;

                    name.setText("Hello " + fullname);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                Toast.makeText(settings.this, "Something wrong happened.", LENGTH_SHORT).show();
            }
        });

        SharedPreferences sP = getSharedPreferences("SORT_TYPE", 0);
        final String SORT = sP.getString("SORT_TYPE", "ID_ASCENDING");
        final int selected;

        if (SORT == "ID_ASCENDING"){
            selected = 0;
        } else if (SORT == "DATE_ASCENDING"){
            selected = 1;
        } else if (SORT == "LVL_ASCENDING"){
            selected = 2;
        } else {
            selected = 0;
        }
        spinner.setSelection(selected);




        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                final String sort_selected = spinner.getItemAtPosition(i).toString();
                sortSave(sort_selected);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {

            }

        });






        toggleDarkMode.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isDarkModeOn){
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO);
                    Toast.makeText(settings.this, "Dark Mode turned off", LENGTH_SHORT).show();
                    editor.putBoolean("isDarkModeOn", false);
                    editor.apply();
                    editor.commit();
                } else {
                    AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
                    Toast.makeText(settings.this, "Dark Mode turned on", LENGTH_SHORT).show();
                    editor.putBoolean("isDarkModeOn", true);
                    editor.apply();
                    editor.commit();
                }
            }
        });

        clearData.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Toast.makeText(settings.this, R.string.clearTab, LENGTH_SHORT).show();
                FirebaseDatabase.getInstance().getReference("Data").child(FirebaseAuth.getInstance().getCurrentUser().getUid()).removeValue();
                clrRemCards();
                backtomain();
            }
        });

        impJSON.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Toast.makeText(settings.this, R.string.jsonUpdate, LENGTH_SHORT).show();
                clrRemCards();
                getRequest(JSONfield.getText().toString());
                backtomain();
            }
        });

        log.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                myDb.clearData();
                logout();
            }
        });

        editProfile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(settings.this, editProfile.class);
                startActivity(i);
            }
        });

    }

    private void logout(){
        Toast.makeText(settings.this, "Logging out...", LENGTH_SHORT).show();
        FirebaseAuth.getInstance().signOut();
        getSharedPreferences("user", MODE_PRIVATE).edit().putBoolean("isnotLogin", true);
        Intent intent = new Intent(this, Login.class);
        startActivity(intent);
        CustomIntent.customType(settings.this, "fadein-to-fadeout");
    }

    private void sortSave(final String a){
        SharedPreferences sharedPreferences = getSharedPreferences("SORT_TYPE", 0);
        final SharedPreferences.Editor editor = sharedPreferences.edit();
        saveSort.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (a.equalsIgnoreCase("By Chronogical Order")){
                    editor.putString("SORT_TYPE", "ID_ASCENDING");
                    editor.apply();
                    editor.commit();
                    Toast.makeText(settings.this, "Sort Type set to Chronological Order", LENGTH_SHORT).show();
                } else if (a.equalsIgnoreCase("By Task Level")) {
                    editor.putString("SORT_TYPE", "LVL_ASCENDING");
                    editor.apply();
                    editor.commit();
                    Toast.makeText(settings.this, "Sort Type set to by Task Level", LENGTH_SHORT).show();
                } else if (a.equalsIgnoreCase("By Task Deadline")) {
                    editor.putString("SORT_TYPE", "DATE_ASCENDING");
                    editor.apply();
                    editor.commit();
                    Toast.makeText(settings.this, "Sort Type set to by Task Deadline", LENGTH_SHORT).show();
                } else {
                    editor.putString("SORT_TYPE", "ID_ASCENDING");
                    editor.apply();
                    editor.commit();
                    Toast.makeText(settings.this, "Sort Type set to Chronological Order", LENGTH_SHORT).show();
                }
            }
        });
    }

    private void addtoDatabase(String a, String b, String c, String d){
        boolean isInserted = myDb.insertData(a, b, c, d);
        if(isInserted){

        }
    }

    private void clrRemCards() {
        myDb.clearData();
    }

    private void parseJson(String json) {
        if (json != ""){
            try {
                JSONObject jsonObject = new JSONObject(json);
                JSONArray jsonArray = jsonObject.getJSONArray("reminders");
                for (int i=0; i < jsonArray.length(); i++) {
                    JSONObject object = jsonArray.getJSONObject(i);
                    String a = object.getString("sbjCode");
                    String b = object.getString("taskDesc");
                    String c = object.getString("taskDate");
                    String d = Integer.toString(object.getInt("taskLvl"));
                    addtoDatabase(a, b, c, d);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    private void getRequest(String url) {

        OkHttpClient client = new OkHttpClient();

        Request request = new Request.Builder()
                .url(url)
                .build();

        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                e.printStackTrace();
                Toast.makeText(settings.this, "Error in URL", LENGTH_SHORT).show();
                backtomain();
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                if (response.isSuccessful()) {
                    final String v = response.body().string();
                    parseJson(v);
                }
            }
        });



    }

    public void backtomain(){
        Intent i = new Intent(this, MainActivity.class);
        startActivity(i);
    }
}
