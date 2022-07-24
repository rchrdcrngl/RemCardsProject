package com.example.reminders;
import android.os.Parcel;
import android.os.Parcelable;
import android.graphics.drawable.Drawable;
import android.widget.Toast;

import com.google.firebase.database.Exclude;

import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;

public class cardrem implements Parcelable{
    private int mImageResource, stat;
    private String sbjCode;
    private String tskDesc;
    private String tskDate;
    private String cardID;
    private int tskLvl;
    private int clrbg;
    int counter = 0;

    public cardrem(){

    }

    public cardrem(String id, String a, String b, String c, int lvl, int stt) {

        cardID = id;
        sbjCode = a;
        tskDesc = b;
        tskDate = c;
        tskLvl = lvl;
        stat = stt;

        if (tskLvl == 1) {
            clrbg = R.color.colorPrimaryLight;
        } else if (tskLvl == 2) {
            clrbg = R.color.grad_b;
        } else if (tskLvl == 3){
            clrbg = R.drawable.gradient_col1;
        } else {
            clrbg = R.drawable.gradient_col1;
            mImageResource = 0;
        }

        switch (stat){
            case 1:  mImageResource = R.drawable.ic_baseline_started; break;
            case 2: mImageResource = R.drawable.ic_baseline_ongoing; break;
            case 3: mImageResource = R.drawable.ic_urgent; break;
            case 4: mImageResource = R.drawable.ic_baseline_finished; break;
            default: mImageResource = R.drawable.ic_baseline_adjust_24; stat = 0; break;
        }

    }



    protected cardrem(Parcel in) {
        mImageResource = in.readInt();
        sbjCode = in.readString();
        tskDesc = in.readString();
        tskDate = in.readString();
        tskLvl = in.readInt();
        clrbg = in.readInt();
        counter = in.readInt();
        cardID = in.readString();

    }

    public static final Creator<cardrem> CREATOR = new Creator<cardrem>() {
        @Override
        public cardrem createFromParcel(Parcel in) {
            return new cardrem(in);
        }

        @Override
        public cardrem[] newArray(int size) {
            return new cardrem[size];
        }
    };

    public int changeStatus(String stat){
        counter = Integer.parseInt(stat);
        counter++;

        switch (counter){
            case 1:  mImageResource = R.drawable.ic_baseline_started; break;
            case 2: mImageResource = R.drawable.ic_baseline_ongoing; break;
            case 3: mImageResource = R.drawable.ic_urgent; break;
            case 4: mImageResource = R.drawable.ic_baseline_finished; break;
            default: mImageResource = R.drawable.ic_baseline_adjust_24; counter = 0; break;
        }

        return counter;
    }

    public String gettskStat(){
        return Integer.toString(stat);
    }

    public String getsbjCode(){
        return sbjCode;
    }

    public String getID(){
        return cardID;
    }
    public String gettskDesc(){
        return tskDesc;
    }

    public String getTskDate(){
        return tskDate;
    }

    public int getImgRsc(){
        return mImageResource;
    }

    public int gettskLvl(){
        return tskLvl;
    }

    public int getbg(){
        return clrbg;
    }


    public void settskStat(int a){
        stat = a;
    }

    public void setsbjCode(String a){
        sbjCode = a;
    }

    public void setID(String a){
        cardID = a;
    }
    public void settskDesc(String a){
        tskDesc = a;
    }

    public void setTskDate(String a){
        tskDate = a;
    }

    public void settskLvl(int a){
        tskLvl = a;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("subjcode", sbjCode);
        result.put("tskdesc", tskDesc);
        result.put("tskdate", tskDate);
        result.put("tsklvl", tskLvl);
        result.put("tskstat", stat);

        return result;
    }




    public static final Comparator<cardrem> BY_ID_ASCENDING = new Comparator<cardrem>(){

        @Override
        public int compare(cardrem A, cardrem B) {
            return A.getID().compareTo(B.getID());
        }
    };

    public static final Comparator<cardrem> BY_LVL_ASCENDING = new Comparator<cardrem>(){

        @Override
        public int compare(cardrem A, cardrem B) {
            return Integer.toString(A.gettskLvl()).compareTo(Integer.toString(B.gettskLvl()));
        }
    };

    public static final Comparator<cardrem> BY_DATE_ASCENDING = new Comparator<cardrem>(){

        @Override
        public int compare(cardrem A, cardrem B) {
            return A.getTskDate().compareTo(B.getTskDate());
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel parcel, int i) {
        parcel.writeInt(mImageResource);
        parcel.writeString(sbjCode);
        parcel.writeString(tskDesc);
        parcel.writeString(tskDate);
        parcel.writeInt(tskLvl);
        parcel.writeInt(clrbg);
        parcel.writeInt(counter);
        parcel.writeString(cardID);
    }
}
