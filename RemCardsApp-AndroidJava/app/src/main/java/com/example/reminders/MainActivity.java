package com.example.reminders;


import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.app.AppCompatDelegate;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.Intent;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.firebase.ui.database.FirebaseRecyclerAdapter;
import com.firebase.ui.database.FirebaseRecyclerOptions;
import com.firebase.ui.database.SnapshotParser;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import org.jetbrains.annotations.NotNull;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.lang.reflect.Array;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import io.paperdb.Paper;
import maes.tech.intentanim.CustomIntent;
import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

import static android.widget.Toast.LENGTH_SHORT;

public class MainActivity extends AppCompatActivity implements View.OnClickListener {


    DatabaseHelper myDb;
    TextView settings;
    LinearLayout isEmpty = findViewById(R.id.isEmpty);
    Button buttonAdd, buttonRefresh;
    RecyclerView mRecyclerView;
    adapterCard mAdapter;
    RecyclerView.LayoutManager mLayoutManager;
    SharedPreferences pref;
    NotificationManagerCompat notificationManager;
    Handler mHandler = new Handler();
    private FirebaseUser user;
    Query UserRef;
    private String userID;


    ArrayList<cardrem> remCards = new ArrayList<cardrem>();
    private RemCardsViewHolder.OnItemClickListener mListener;


    @Override
    protected void onStart() {
        super.onStart();
        //enabled Persistent Database
        FirebaseDatabase.getInstance().setPersistenceEnabled(true);

        //SORT TYPE [FIX!]
        SharedPreferences sharedPreferences = getSharedPreferences("SORT_TYPE", 0);
        final String SORT = sharedPreferences.getString("SORT_TYPE", "ID_ASCENDING");

        FirebaseRecyclerOptions<cardrem> options = new FirebaseRecyclerOptions.Builder<cardrem>()
                .setQuery(UserRef, new SnapshotParser<cardrem>() {
                    @NonNull
                    @Override
                    public cardrem parseSnapshot(@NonNull DataSnapshot snapshot) {
                        remCards.add(new cardrem(snapshot.getKey(),
                                snapshot.child("subjcode").getValue().toString(),
                                snapshot.child("tskdesc").getValue().toString(),
                                snapshot.child("tskdate").getValue().toString(),
                                Integer.parseInt(snapshot.child("tsklvl").getValue().toString()),
                                Integer.parseInt(snapshot.child("tskstat").getValue().toString())));
                        return new cardrem(snapshot.getKey(),
                                snapshot.child("subjcode").getValue().toString(),
                                snapshot.child("tskdesc").getValue().toString(),
                                snapshot.child("tskdate").getValue().toString(),
                                Integer.parseInt(snapshot.child("tsklvl").getValue().toString()),
                                Integer.parseInt(snapshot.child("tskstat").getValue().toString()));
                    }
                })
                .build();

        FirebaseRecyclerAdapter<cardrem, RemCardsViewHolder> adapter = new FirebaseRecyclerAdapter<cardrem, RemCardsViewHolder>(options) {


            @Override
            protected void onBindViewHolder(@NonNull RemCardsViewHolder holder, final int i, @NonNull final cardrem cardrem) {
                holder.mImageView.setImageResource(cardrem.getImgRsc());
                holder.sbjCode.setText(cardrem.getsbjCode());
                holder.tskDesc.setText(cardrem.gettskDesc());
                holder.tskDate.setText(cardrem.getTskDate());
                holder.colorCar.setBackgroundResource(cardrem.getbg());
                holder.mImageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        String stat = cardrem.gettskStat();
                        String a = Integer.toString(cardrem.changeStatus(stat));
                        updateStatus(cardrem.getID(), a);
                        //mAdapter.notifyItemChanged(i);
                        //refreshApp();
                    }
                });
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        String a = cardrem.getID();
                        editCard(i);
                    }
                });



            }

            @NonNull
            @Override
            public RemCardsViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.cardrem, parent, false);
                RemCardsViewHolder cvh = new RemCardsViewHolder(v,mListener);
                return cvh;

            }
        };


        mRecyclerView.setAdapter(adapter);
        adapter.startListening();
        if (SORT.equals("ID_ASCENDING")){
            Collections.sort(remCards, cardrem.BY_ID_ASCENDING);//Ascending by ID
        } else if (SORT.equals("LVL_ASCENDING")) {
            Collections.sort(remCards, cardrem.BY_LVL_ASCENDING);//Ascending by LVL
        } else if (SORT.equals("DATE_ASCENDING")) {
            Collections.sort(remCards, cardrem.BY_DATE_ASCENDING);//Ascending by DATE
        } else {
            Collections.sort(remCards, cardrem.BY_ID_ASCENDING);//Ascending by ID
        }
        adapter.notifyDataSetChanged();
        new ItemTouchHelper(iTHC).attachToRecyclerView(mRecyclerView);

    }


    private void updateStatus(String id, String a){
        int tskstat = Integer.parseInt(a);
        String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        FirebaseDatabase.getInstance().getReference("Data").child(uid).child(id).child("tskstat").setValue(tskstat);
    }
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        //update widget
        updateWidget();

        //makeNotif();
        String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        DatabaseReference scoresRef = FirebaseDatabase.getInstance().getReference("Data").child(uid);
        scoresRef.keepSynced(true);
        UserRef = FirebaseDatabase.getInstance().getReference("Data").child(uid);



        setContentView(R.layout.activity_main);

        //declare objects on Main
        notificationManager = NotificationManagerCompat.from(this);
        buttonRefresh = findViewById(R.id.button_refresh);
        buttonRefresh.setOnClickListener(this);
        settings = findViewById(R.id.settings);
        myDb = new DatabaseHelper(this);
        buttonAdd = findViewById(R.id.button_add);
        buttonAdd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addView();
            }
        });
        settings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                gotoSettings();
            }
        });


        //load data

        mRecyclerView = findViewById(R.id.recyclerview);
        mRecyclerView.setLayoutManager(new LinearLayoutManager(this));

        // check if no tasks
       // emptyTask();


        //startservice
        startService();
    }


    private void buildRecyclerView() {

        SharedPreferences sharedPreferences = getSharedPreferences("SORT_TYPE", 0);
        final String SORT = sharedPreferences.getString("SORT_TYPE", "ID_ASCENDING");


        if (SORT.equals("ID_ASCENDING")){
            Collections.sort(remCards, cardrem.BY_ID_ASCENDING);//Ascending by ID
        } else if (SORT.equals("LVL_ASCENDING")) {
            Collections.sort(remCards, cardrem.BY_LVL_ASCENDING);//Ascending by LVL
        } else if (SORT.equals("DATE_ASCENDING")) {
            Collections.sort(remCards, cardrem.BY_DATE_ASCENDING);//Ascending by DATE
        } else {
            Collections.sort(remCards, cardrem.BY_ID_ASCENDING);//Ascending by ID
        }




        mRecyclerView = findViewById(R.id.recyclerview);
        mRecyclerView.setHasFixedSize(true);
        mLayoutManager = new LinearLayoutManager(this);
        mAdapter = new adapterCard(remCards);
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);

        new ItemTouchHelper(iTHC).attachToRecyclerView(mRecyclerView);

        mAdapter.setOnItemClickListener(new adapterCard.OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                String a = remCards.get(position).getID();
                editCard(position);

            }

            @Override
            public void onChangeStatus(int position) {
                String stat = remCards.get(position).gettskStat();
                String a = Integer.toString(remCards.get(position).changeStatus(stat));
                int id = Integer.parseInt(remCards.get(position).getID());
                String id_str = Integer.toString(id + 1);
                mAdapter.notifyItemChanged(position);
                boolean isUpdate = myDb.updateStatus(id_str, a);
                refreshApp();
            }
        });
    }


    public void gotoSettings(){
        Intent i = new Intent(this, settings.class);
        startActivity(i);
        CustomIntent.customType(MainActivity.this, "right-to-left");
    }
    @Override
    public void onClick(View view) {
        refreshApp();
    }

    private void startService(){
        mHandler.postDelayed(refreshRunnable, 1000000);
    }

    private Runnable refreshRunnable = new Runnable(){

        @Override
        public void run() {
            refreshApp();
            mHandler.postDelayed(this, 1000000);
        }
    };

    private void refreshApp() {
        String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
        DatabaseReference scoresRef = FirebaseDatabase.getInstance().getReference("Data").child(uid);
        scoresRef.keepSynced(true);
        MainActivity.this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateWidget();
            }
        });
    }

    private void emptyTask(){
        if (remCards.isEmpty()){
            isEmpty.setVisibility(LinearLayout.VISIBLE);
        }
    }

    public void editCard(int pos){
        Intent intent = new Intent(this, editCards.class);
        intent.putExtra("Data", remCards.get(pos));
        startActivity(intent);
        CustomIntent.customType(MainActivity.this, "left-to-right");
    }

    public void addView(){
        Intent intent = new Intent(this, addCards.class);
        startActivity(intent);
        CustomIntent.customType(MainActivity.this, "left-to-right");
    }


    public void removeItem(int position){
        removeDatabase(remCards.get(position).getID());

    }

    private void removeDatabase(final String id) {
        FirebaseDatabase.getInstance().getReference("Data")
                .child(FirebaseAuth.getInstance().getCurrentUser().getUid())
                .child(id)
                .removeValue().addOnCompleteListener(new OnCompleteListener<Void>() {
            @Override
            public void onComplete(@NonNull Task<Void> task) {
                if(!task.isSuccessful()) {
                    Toast.makeText(MainActivity.this, "Error Deleting Card", Toast.LENGTH_SHORT).show();
                }
            }
        });

    }

    private void updateWidget(){
        Paper.init(this);
        Paper.book().write("task_count", remCards.size());
        //Toast.makeText(this, remCards.size(), Toast.LENGTH_SHORT).show();
    }

    private void makeNotif(){
        Notification notification = new NotificationCompat.Builder(this, app.CHANNEL_1_ID)
                .setContentTitle("subjCode")
                .setContentText("tskDesc")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_MESSAGE)
                .setSmallIcon(R.drawable.ic_baseline_adjust_24)
                .build();

        notificationManager.notify(1, notification);


    }



    ItemTouchHelper.SimpleCallback iTHC = new ItemTouchHelper.SimpleCallback(0, ItemTouchHelper.RIGHT | ItemTouchHelper.LEFT) {
        @Override
        public boolean onMove(@NonNull RecyclerView recyclerView, @NonNull RecyclerView.ViewHolder viewHolder, @NonNull RecyclerView.ViewHolder target) {
            return false;
        }

        @Override
        public void onSwiped(@NonNull RecyclerView.ViewHolder viewHolder, int direction) {
            int x = viewHolder.getAdapterPosition();
            removeItem(x);
        }
    };



    public static class RemCardsViewHolder extends RecyclerView.ViewHolder {
        private ArrayList<cardrem> remcard;
        private RemCardsViewHolder.OnItemClickListener mListener;

        public interface OnItemClickListener {
            void onItemClick(int position);
            void onChangeStatus(int position);
        }

        public void setOnItemClickListener(RemCardsViewHolder.OnItemClickListener listener) {
            mListener = listener;
        }



        public ImageView mImageView;
        public TextView sbjCode;
        public TextView tskDesc;
        public TextView tskDate;
        public TextView tskLvl;
        public LinearLayout colorCar;

        public RemCardsViewHolder(@NonNull View itemView, final OnItemClickListener listener) {
            super(itemView);
            mImageView = itemView.findViewById(R.id.levelsign);
            sbjCode = itemView.findViewById(R.id.subject_code);
            tskDesc = itemView.findViewById(R.id.description);
            tskDate = itemView.findViewById(R.id.date);
            colorCar = itemView.findViewById(R.id.cardClr);

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(listener != null){
                        int position = getAdapterPosition();
                        if (position != RecyclerView.NO_POSITION){
                            listener.onItemClick(position);
                        }
                    }
                }
            });

            mImageView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(listener != null){
                        int position = getAdapterPosition();
                        if (position != RecyclerView.NO_POSITION){
                            listener.onChangeStatus(position);
                        }
                    }
                }
            });



        }
    }

}

