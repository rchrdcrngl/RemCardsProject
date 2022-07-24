package com.example.reminders;

import com.google.firebase.database.Exclude;

import java.util.HashMap;
import java.util.Map;

public class SQLParse {

    public String subjcode, tskdesc, tskdate;
    public int tsklvl;
    public int tskstat;

    SQLParse(){

    }

    public SQLParse(String subjcode, String tskdesc, String tskdate, int tsklvl, int tskstat){
        this.subjcode = subjcode;
        this.tskdate = tskdate;
        this.tskdesc = tskdesc;
        this.tsklvl = tsklvl;
        this.tskstat = tskstat;
    }

    @Exclude
    public Map<String, Object> toMap() {
        HashMap<String, Object> result = new HashMap<>();
        result.put("subjcode", subjcode);
        result.put("tskdesc", tskdesc);
        result.put("tskdate", tskdate);
        result.put("tsklvl", tsklvl);
        result.put("tskstat", tskstat);

        return result;
    }
}
