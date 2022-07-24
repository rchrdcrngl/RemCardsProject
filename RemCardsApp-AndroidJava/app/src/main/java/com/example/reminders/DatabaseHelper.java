package com.example.reminders;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

import androidx.annotation.Nullable;

public class DatabaseHelper extends SQLiteOpenHelper {
    public static final String DATABASE_NAME = "remDatabase.db";
    public static final String TABLE_NAME = "remData_table";
    public static final String COL_1 = "ID";
    public static final String COL_2 = "SUBJCODE";
    public static final String COL_3 = "TSKDESC";
    public static final String COL_4 = "TSKDATE";
    public static final String COL_5 = "TSKLVL";
    public static final String COL_6 = "TSKSTATUS";


    public DatabaseHelper(Context context) {
        super(context, DATABASE_NAME, null, 1);

    }

    @Override
    public void onCreate(SQLiteDatabase sqLiteDatabase) {
        String createTable = "CREATE TABLE " + TABLE_NAME + " (ID INTEGER PRIMARY KEY AUTOINCREMENT, SUBJCODE TEXT, TSKDESC TEXT, TSKDATE TEXT, TSKLVL INTEGER, TSKSTATUS INTEGER)";
        sqLiteDatabase.execSQL(createTable);
    }

    @Override
    public void onUpgrade(SQLiteDatabase sqLiteDatabase, int i, int i1) {
        sqLiteDatabase.execSQL("DROP TABLE IF EXISTS " + TABLE_NAME);
        onCreate(sqLiteDatabase);
    }

    public boolean insertData(String subjCode, String tskDesc, String tskDate, String tskLvl){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        int i = Integer.parseInt(tskLvl);
        contentValues.put(COL_6, 0);
        contentValues.put(COL_2, subjCode);
        contentValues.put(COL_3, tskDesc);
        contentValues.put(COL_4, tskDate);
        contentValues.put(COL_5, i);
        long result = db.insert(TABLE_NAME,null,contentValues);
        if (result== -1){
            return false;
        } else {
            return true;
        }
    }

    public boolean firebaseData(String card_id, String subjCode, String tskDesc, String tskDate, String tskLvl, String tskStat){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        int i = Integer.parseInt(tskLvl);
        contentValues.put(COL_1, card_id);
        contentValues.put(COL_6, tskStat);
        contentValues.put(COL_2, subjCode);
        contentValues.put(COL_3, tskDesc);
        contentValues.put(COL_4, tskDate);
        contentValues.put(COL_5, i);
        long result = db.insert(TABLE_NAME,null,contentValues);
        if (result== -1){
            return false;
        } else {
            return true;
        }
    }

    public Cursor getAllData(){
        SQLiteDatabase db = this.getWritableDatabase();
        Cursor res = db.rawQuery("select * from " + TABLE_NAME, null);
        return res;
    }

    public Integer deleteData (String id){
        SQLiteDatabase db = this.getWritableDatabase();
        return db.delete(TABLE_NAME, "ID = ?", new String[] {id});
    }



    public void clearData(){
        SQLiteDatabase db = this.getWritableDatabase();
        db.delete(TABLE_NAME, null, null);
    }

    public boolean updateData(String id, String subjCode, String tskDesc, String tskDate, String tskLvl){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        int i = Integer.parseInt(tskLvl);
        int a = Integer.parseInt(id);
        contentValues.put(COL_1, a);
        contentValues.put(COL_2, subjCode);
        contentValues.put(COL_3, tskDesc);
        contentValues.put(COL_4, tskDate);
        contentValues.put(COL_5, i);
        db.update(TABLE_NAME, contentValues, "ID = ?", new String[] {id});
        return true;
    }

    public boolean updateStatus(String id, String tskStatus){
        SQLiteDatabase db = this.getWritableDatabase();
        ContentValues contentValues = new ContentValues();
        int i = Integer.parseInt(tskStatus);
        contentValues.put(COL_6, i);
        int a = Integer.parseInt(id);
        contentValues.put(COL_1, a);
        db.update(TABLE_NAME, contentValues, "ID = ?", new String[] {id});
        return true;
    }
}
