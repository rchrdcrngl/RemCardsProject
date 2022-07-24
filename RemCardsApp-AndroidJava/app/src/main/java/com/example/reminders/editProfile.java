package com.example.reminders;

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

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import maes.tech.intentanim.CustomIntent;

import static android.widget.Toast.LENGTH_SHORT;

public class editProfile extends AppCompatActivity {
    private FirebaseAuth mAuth;
    private EditText name_frm, email_frm;
    private Button edit, changepass;
    private ProgressBar progressBar;

    private FirebaseUser user;
    private DatabaseReference reference;
    private String userID;
    private String password = "";


    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.editprofile);
        edit = findViewById(R.id.btn_editprof);
        name_frm = findViewById(R.id.edit_name);
        email_frm = findViewById(R.id.edit_email);
        progressBar = findViewById(R.id.progressBar_editprof);
        changepass = findViewById(R.id.btn_changepass);
        ConstraintLayout constraintLayout = (ConstraintLayout) findViewById(R.id.bg_edit);
        AnimationDrawable animationDrawable = (AnimationDrawable) constraintLayout.getBackground();
        animationDrawable.setEnterFadeDuration(2000);
        animationDrawable.setExitFadeDuration(4000);
        animationDrawable.start();
        FirebaseAuth auth;


        user = FirebaseAuth.getInstance().getCurrentUser();
        reference = FirebaseDatabase.getInstance().getReference("Users");
        userID = user.getUid();

        reference.child(userID).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                User userProfile = dataSnapshot.getValue(User.class);
                if(userProfile!=null){
                    String fullname = userProfile.nameUser;
                    String email = userProfile.email;
                    password = userProfile.password;

                    name_frm.setText(fullname);
                    email_frm.setText(email);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                Toast.makeText(editProfile.this, "Something wrong happened.", LENGTH_SHORT).show();
            }
        });

        edit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String name = name_frm.getText().toString();
                String email = email_frm.getText().toString();

                User user = new User(name, email, password);
                FirebaseDatabase.getInstance().getReference("Users")
                        .child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                        .setValue(user).addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if(!task.isSuccessful()) Toast.makeText(editProfile.this, "Error Updating Profile", Toast.LENGTH_SHORT).show();
                    }
                });
            }
        });

        changepass.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                resetPassword();
            }
        });

    }

    private void resetPassword(){
        String email = email_frm.getText().toString().trim();
        String name = name_frm.getText().toString().trim();


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
                   Toast.makeText(editProfile.this, "Check your email to reset your password!", LENGTH_SHORT).show();
                } else {
                    Toast.makeText(editProfile.this, "Error in resetting your password.", LENGTH_SHORT).show();
                }
                progressBar.setVisibility(View.GONE);
            }
        });
    }
}
