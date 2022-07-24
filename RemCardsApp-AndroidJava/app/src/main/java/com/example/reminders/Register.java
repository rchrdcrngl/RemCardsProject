package com.example.reminders;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.os.Bundle;
import android.util.Patterns;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;

import java.util.regex.Pattern;

import maes.tech.intentanim.CustomIntent;

public class Register extends AppCompatActivity {

    private FirebaseAuth mAuth;
    private TextView oldUser;
    private EditText name_frm, email_frm, password_frm;
    private Button register;
    private ProgressBar progressBar;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_register);
        ConstraintLayout constraintLayout = (ConstraintLayout) findViewById(R.id.bg_register);
        AnimationDrawable animationDrawable = (AnimationDrawable) constraintLayout.getBackground();
        animationDrawable.setEnterFadeDuration(2000);
        animationDrawable.setExitFadeDuration(4000);
        animationDrawable.start();
        mAuth = FirebaseAuth.getInstance();
        register = findViewById(R.id.btn_register);
        oldUser = findViewById(R.id.old_user);
        email_frm = findViewById(R.id.reg_email);
        password_frm = findViewById(R.id.reg_password);
        name_frm = findViewById(R.id.form_name);
        progressBar = findViewById(R.id.progressBar_register);


        oldUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(Register.this, Login.class);
                startActivity(i);
                CustomIntent.customType(Register.this, "fadein-to-fadeout");
            }
        });

        register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                registerUser();
            }
        });

    }

    private void registerUser(){
        final String name = name_frm.getText().toString().trim();
        final String email = email_frm.getText().toString().trim();
        final String password = password_frm.getText().toString().trim();

        if(name.isEmpty()){
            name_frm.setError("Full Name is required!");
            name_frm.requestFocus();
            return;
        }

        if(email.isEmpty()){
            email_frm.setError("Email is required!");
            email_frm.requestFocus();
            return;
        }

        if(password.isEmpty()){
            password_frm.setError("Password is required!");
            password_frm.requestFocus();
            return;
        }

        if(password.length() < 6){
            password_frm.setError("Password should be more than or equal to 6. characters.");
            password_frm.requestFocus();
            return;
        }

        if(!Patterns.EMAIL_ADDRESS.matcher(email).matches()){
            email_frm.setError("Please enter valid email address!");
            email_frm.requestFocus();
            return;
        }

        progressBar.setVisibility(View.VISIBLE);
        mAuth.createUserWithEmailAndPassword(email, password)
                .addOnCompleteListener(new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {
                        if(task.isSuccessful()){
                            User user = new User(name, email, password);

                            FirebaseDatabase.getInstance().getReference("Users")
                                    .child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                                    .setValue(user).addOnCompleteListener(new OnCompleteListener<Void>() {
                                @Override
                                public void onComplete(@NonNull Task<Void> task) {
                                    if(task.isSuccessful()) {
                                        Toast.makeText(Register.this, "User has been registered successfully!", Toast.LENGTH_SHORT).show();
                                        progressBar.setVisibility(View.GONE);
                                        Intent i = new Intent(Register.this, Login.class);
                                        startActivity(i);
                                        CustomIntent.customType(Register.this, "fadein-to-fadeout");
                                    }  else {
                                        Toast.makeText(Register.this, "Failed to register. Try Again!", Toast.LENGTH_SHORT).show();
                                        progressBar.setVisibility(View.GONE);
                                    }
                                }
                            });
                        } else {
                            Toast.makeText(Register.this, "Failed to register. Try Again!", Toast.LENGTH_SHORT).show();
                            progressBar.setVisibility(View.GONE);
                        }
                    }
                });
    }
}