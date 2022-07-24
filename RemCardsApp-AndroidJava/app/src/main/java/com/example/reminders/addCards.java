package com.example.reminders;

import android.annotation.SuppressLint;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Map;

import maes.tech.intentanim.CustomIntent;

import static android.widget.Toast.LENGTH_SHORT;

public class addCards extends AppCompatActivity implements DatePickerDialog.OnDateSetListener {
    Button add;
    TextView frmsubjCode, frmtskDesc, frmtskDate, frmtskLvl;
    DatabaseHelper myDb;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.remcardform);
        myDb = new DatabaseHelper(this);
        add = findViewById(R.id.btn_add);
        frmsubjCode = findViewById(R.id.form_sbjcode);
        frmtskDesc = findViewById(R.id.form_tskdesc);
        frmtskDate = findViewById(R.id.form_tskdate);
        final Spinner spinner = (Spinner) findViewById(R.id.form_tsklvl);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.tsklevelselector, R.layout.spinner2_textview);
        adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(adapter);
        spinner.setSelection(0);





        spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int i, long l) {
                final String a = spinner.getItemAtPosition(i).toString();
                final int lvl;
                if (a.equals("Low Priority")){
                    lvl = 1;
                } else if (a.equals("Mid Priority")) {
                    lvl = 2;
                } else if (a.equals("High Priority")) {
                    lvl = 3;
                } else {
                    lvl = 1;
                }
                btnClick(add, lvl);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
                btnClick(add, 1);
            }

        });




        frmtskDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showDatePicker();
            }
        });



    }

    public void btnClick(final Button btn, final int str){
        final String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String key = FirebaseDatabase.getInstance().getReference("Data").child(uid).push().getKey();
                cardrem card = new cardrem(key, frmsubjCode.getText().toString(), frmtskDesc.getText().toString(), frmtskDate.getText().toString(), str, 0);
                Map<String, Object> cardValues = card.toMap();
                FirebaseDatabase.getInstance().getReference("Data").child(uid).child(key).updateChildren(cardValues).addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()){
                            Toast.makeText(addCards.this, "RemCard Added Successfully", LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(addCards.this, "Error Adding RemCard", LENGTH_SHORT).show();
                        }
                    }
                });

                backtomain();
            }
        });
    }




    private void showDatePicker() {
        DatePickerDialog datePickerDialog = new DatePickerDialog(
                this,
                this,
                Calendar.getInstance().get(Calendar.YEAR),
                Calendar.getInstance().get(Calendar.MONTH),
                Calendar.getInstance().get(Calendar.DAY_OF_MONTH)
        );
        datePickerDialog.show();
    }



    @Override
    public void onDateSet(DatePicker datePicker, int i, int i1, int i2) {
        String date = (i1 + 1) + "/" + i2 + "/" + i;
        frmtskDate.setText(date);
    }

    public void backtomain(){
        Intent i = new Intent(this, MainActivity.class);
        startActivity(i);
        CustomIntent.customType(addCards.this, "right-to-left");
    }


}
