package com.example.reminders;

import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.FirebaseDatabase;

import java.util.Calendar;
import java.util.Map;

import maes.tech.intentanim.CustomIntent;

import static android.widget.Toast.LENGTH_SHORT;

public class editCards extends AppCompatActivity implements DatePickerDialog.OnDateSetListener{
    Button add;
    TextView header;
    EditText frmsubjCode, frmtskDesc, frmtskDate;
    DatabaseHelper myDb;
    int selected;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.remcardform);
        myDb = new DatabaseHelper(this);
        add = findViewById(R.id.btn_add);
        frmsubjCode = findViewById(R.id.form_sbjcode);
        frmtskDesc = findViewById(R.id.form_tskdesc);
        frmtskDate = findViewById(R.id.form_tskdate);
        header = findViewById(R.id.form_header);

        final Spinner spinner = (Spinner) findViewById(R.id.form_tsklvl);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(this, R.array.tsklevelselector, R.layout.spinner2_textview);
        adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
        spinner.setAdapter(adapter);


        Intent intent = getIntent();
        cardrem data = intent.getParcelableExtra("Data");

        //ID Translation
        final String cardID = data.getID();

        final String sbj = data.getsbjCode();
        String desc = data.gettskDesc();
        String date = data.getTskDate();
        String lvel = Integer.toString(data.gettskLvl());

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
                btnClick(add, lvl, cardID);
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
                btnClick(add, 1, cardID);
            }

        });

        frmtskDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showDatePicker();
            }
        });

        if (lvel.equals("1")){
            selected = 0;
        } else if (lvel.equals("2")){
            selected = 1;
        } else if (lvel.equals("3")){
            selected = 2;
        } else {
            selected = 0;
        }

        frmsubjCode.setText(sbj);
        frmtskDesc.setText(desc);
        frmtskDate.setText(date);
        header.setText("Edit Rem Cards");
        add.setText("Edit");
        spinner.setSelection(selected);

        final String lvl = spinner.getSelectedItem().toString();


    }

    public void btnClick(final Button btn, final int lvl, final String cardID){
        final String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
                FirebaseDatabase.getInstance().getReference("Data").child(uid).child(cardID).child("subjcode").setValue(frmsubjCode.getText().toString());
                FirebaseDatabase.getInstance().getReference("Data").child(uid).child(cardID).child("tskdesc").setValue(frmtskDesc.getText().toString());
                FirebaseDatabase.getInstance().getReference("Data").child(uid).child(cardID).child("tskdate").setValue(frmtskDate.getText().toString());
                FirebaseDatabase.getInstance().getReference("Data").child(uid).child(cardID).child("tsklvl").setValue(lvl).addOnCompleteListener(new OnCompleteListener<Void>() {
                    @Override
                    public void onComplete(@NonNull Task<Void> task) {
                        if (task.isSuccessful()){
                            Toast.makeText(editCards.this, "RemCard Edited Successfully", LENGTH_SHORT).show();
                        } else {
                            Toast.makeText(editCards.this, "Error Editing RemCard", LENGTH_SHORT).show();
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

    public void backtomain(){
        Intent i = new Intent(this, MainActivity.class);
        startActivity(i);
        CustomIntent.customType(editCards.this, "right-to-left");
    }

    @Override
    public void onDateSet(DatePicker datePicker, int i, int i1, int i2) {
        String date = (i1 + 1) + "/" + i2 + "/" + i;
        frmtskDate.setText(date);
    }
}
