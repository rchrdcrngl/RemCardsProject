import 'package:flutter/material.dart';
import 'package:flutter_timetable_view/flutter_timetable_view.dart';

class Period {
  final String id;
  final int day;
  final String name;
  final int hourStart;
  final int minStart;
  final int hourFinish;
  final int minFinish;
  static List<Period> list = [];

  static void setList(List<Period> lst) {
    list = lst;
  }

  const Period(
      {this.day,
      this.id,
      this.name,
      this.hourStart,
      this.minStart,
      this.hourFinish,
      this.minFinish});

  factory Period.fromJson(int dayStr, Map<String, dynamic> json) {
    var startTime = json['startTime'];
    var endTime = json['endTime'];
    var start = startTime.split(":");
    var end = endTime.split(":");
    var hS = int.parse(start[0]);
    var mS = int.parse(start[1]);
    var hF = int.parse(end[0]);
    var mF = int.parse(end[1]);
    return Period(
        day: dayStr,
        id: json["_id"].toString(),
        name: json["subject"].toString(),
        hourStart: hS,
        minStart: mS,
        hourFinish: hF,
        minFinish: mF);
  }

  TableEvent convert({Function edit}) {
    list.add(this);
    return TableEvent(
        textStyle: TextStyle(color: Colors.deepOrange[800], fontSize: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), color: Colors.orange[50]),
        title: this.name,
        start: TableEventTime(hour: this.hourStart, minute: this.minStart),
        end: TableEventTime(hour: this.hourFinish, minute: this.minFinish),
        onTap: () => edit(this.day, this.id, this.name, this.hourStart,
            this.minStart, this.hourFinish, this.minFinish));
  }
}
