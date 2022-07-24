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
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.FirebaseDatabase;

import maes.tech.intentanim.CustomIntent;

import static android.widget.Toast.LENGTH_SHORT;

public class Login extends AppCompatActivity {

    private FirebaseAuth mAuth;
    private TextView forgotPass, newUser;
    private EditText email_frm, password_frm;
    private Button login;
    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);
        ConstraintLayout constraintLayout = (ConstraintLayout) findViewById(R.id.bg_login);
        AnimationDrawable animationDrawable = (AnimationDrawable) constraintLayout.getBackground();
        animationDrawable.setEnterFadeDuration(2000);
        animationDrawable.setExitFadeDuration(4000);
        animationDrawable.start();
        mAuth = FirebaseAuth.getInstance();
        login = findViewById(R.id.btn_login);
        forgotPass = findViewById(R.id.forgot_pass);
        newUser = findViewById(R.id.new_user);
        email_frm = findViewById(R.id.form_email);
        password_frm = findViewById(R.id.form_password);
        progressBar = findViewById(R.id.progressBar_login);

        forgotPass.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                resetPassword();
            }
        });

        newUser.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(Login.this, Register.class);
                startActivity(i);
                CustomIntent.customType(Login.this, "fadein-to-fadeout");
            }
        });

        login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                userLogin();
            }
        });

    }

    private void userLogin(){
        final String email = email_frm.getText().toString().trim();
        final String password = password_frm.getText().toString().trim();


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

        if(!Patterns.EMAIL_ADDRESS.matcher(email).matches()){
            email_frm.setError("Please enter valid email address!");
            email_frm.requestFocus();
            return;
        }

        progressBar.setVisibility(View.VISIBLE);

        mAuth.signInWithEmailAndPassword(email, password).addOnCompleteListener(new OnCompleteListener<AuthResult>() {
            @Override
            public void onComplete(@NonNull Task<AuthResult> task) {
               if(task.isSuccessful()){
                   FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                   if(user.isEmailVerified()){
                       getSharedPreferences("user", MODE_PRIVATE).edit().putBoolean("isnotLogin", false);
                       Intent i = new Intent(Login.this, MainActivity.class);
                       i.putExtra("login", true);
                       startActivity(i);
                       CustomIntent.customType(Login.this, "fadein-to-fadeout");
                   } else {
                       user.sendEmailVerification();
                       Toast.makeText(Login.this, "Check your email to verify your account", Toast.LENGTH_SHORT).show();
                       progressBar.setVisibility(View.GONE);
                   }
               }else {
                   Toast.makeText(Login.this, "Login Error. Try Again!", Toast.LENGTH_SHORT).show();
                   progressBar.setVisibility(View.GONE);
               }
            }
        });
    }

    private void resetPassword(){
        String email = email_frm.getText().toString().trim();


        if(email.isEmpty()){
            email_frm.setError("Email is required!");
            email_frm.requestFocus();
            return;
        }



        if(!Patterns.EMAIL_ADDRESS.matcher(email).matches()){
            email_frm.setError("Please enter valid email address!");
            email_frm.requestFocus();
            return;
        }

        progressBar.setVisibility(View.VISIBLE);
        mAuth.sendPasswordResetEmail(email).addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                if(task.isSuccessful()){
                    Toast.makeText(Login.this, "Check your email to reset your password!", LENGTH_SHORT).show();
                } else {
                    Toast.makeText(Login.this, "Error in resetting your password.", LENGTH_SHORT).show();
                }
                progressBar.setVisibility(View.GONE);
            }
        });
    }
}