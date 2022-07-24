package com.example.reminders;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.FirebaseDatabase;

import maes.tech.intentanim.CustomIntent;

public class SplashScreen extends AppCompatActivity {


    private FirebaseAuth firebaseAuth;
    FirebaseAuth.AuthStateListener mAuthListener;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //check for darkmode
        SharedPreferences sharedPreferences = getSharedPreferences("DarkMode", MODE_PRIVATE);
        final boolean isDarkModeOn = sharedPreferences.getBoolean("isDarkModeOn", false);
        if (isDarkModeOn){
            AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_YES);
        }

        firebaseAuth = FirebaseAuth.getInstance();

    }

    @Override
    protected void onStart() {
        super.onStart();
        FirebaseUser firebaseUser = firebaseAuth.getCurrentUser();
        if(firebaseUser!=null){
            Intent intent = new Intent(SplashScreen.this, MainActivity.class);
            startActivity(intent);
            CustomIntent.customType(SplashScreen.this, "fadein-to-fadeout");
            finish();
        } else {
            Intent intent = new Intent(SplashScreen.this, Login.class);
            startActivity(intent);
            CustomIntent.customType(SplashScreen.this, "fadein-to-fadeout");
            finish();
        }
    }
}


