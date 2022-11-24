import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_timetable_view/flutter_timetable_view.dart';
import 'package:get/get.dart';
import 'package:remcards/components/notifications.dart';
import 'package:remcards/pages/addsched.dart';
import 'package:remcards/pages/components/ScheduleHeader.dart';
import 'package:remcards/pages/editsched.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'components/AppBar.dart';
import 'components/EventTable.dart';

class SchedulePage extends StatefulWidget {
  final bool isRefresh;
  SchedulePage({Key key, this.isRefresh = false}) : super(key: key);
  static _SchedulePageState of(BuildContext context) =>
      context.findAncestorStateOfType<_SchedulePageState>();
  @override
  _SchedulePageState createState() => _SchedulePageState();
}



edit(int day, String id, String title, int hourStart, int minStart,
    int hourFinish, int minFinish) {
  Get.to(() => editSchedForm(
      day, id, title, hourStart, minStart, hourFinish, minFinish));
}

class dayTable {
  final String id;
  final int day;
  final List<dynamic> data;
  const dayTable({this.id, this.day, this.data});

  factory dayTable.fromJson(Map<String, dynamic> json) {
    return dayTable(
        id: json["_id"].toString(),
        day: json["day"],
        data: json["data"]);
  }

  String toString() {
    return "dayTable: " + id + " " + day.toString() + " " + data.toString();
  }
}

processNotification(List<dayTable> resp) async {
  print("STARTING TO PROCESS NOTIF");
  for (dayTable daytbl1 in resp) {
    if (daytbl1.data != null) {
      daytbl1.data.forEach((element) {
        eventTable tbe = eventTable.fromJson(daytbl1.day, element);
        createScheduledNotification(
            1, tbe.day, tbe.hourStart, tbe.minStart, tbe.name);
      });
    }
  }
  print("All notifications are scheduled");
}


Map<int, String> numToDay = {1:'Monday',2:'Tuesday',3:'Wednesday',4:'Thursday',5:'Friday',6:'Saturday',7:'Sunday'};

class _SchedulePageState extends State<SchedulePage> {
  List<dayTable> dayTableList = [];

  add() => Get.to(() => addSchedForm(refresh: _refresh));

  _refresh() => setState(() {
        refresh();
      });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: rcAppBarActions("Schedule", <Widget>[
        IconButton(
          icon: Icon(Icons.refresh),
          iconSize: 15,
          onPressed: _refresh,
        )
      ]),
      body: Container(
        child: TimetableView(
            laneEventsList: _buildLaneEvents(width),
            timetableStyle: TimetableStyle(
                //timelineItemColor: Colors.orange[50],
                timeItemTextColor: Colors.brown,
                laneWidth: (width / 8),
                timeItemWidth: (width / 8))),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: Colors.orangeAccent,
          onPressed: () {
            add();
          }),
    );
  }

  loadPosts() async {
    print("load-posts");
    fetchPost().then((data) {
      setState(() {
        dayTableList = data;
      });
    });
  }

  Future<Null> refresh() async {
    APICacheManager().deleteCache("API-Schedule");
    cancelScheduledNotifications();
    loadPosts();
    return null;
  }

  @override
  void initState() {
    super.initState();
    loadPosts();
    if (widget.isRefresh) {
      _refresh();
    }
  }

  Future fetchPost([howMany = 5]) async {
    var cacheExists =
        await APICacheManager().isAPICacheKeyExist("API-Schedule");
    if (!cacheExists) {
      print("fetch posts");
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("token");
      Map<String, String> headers = {
        'Accept': '*/*',
        "Access-Control_Allow_Origin": "*",
        "Content-Type": "application/json",
        "x-access-token": token,
      };
      print("response");
      final response = await http.get(Uri.parse(schedURI), headers: headers);
      print(response.statusCode);
      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel =
            new APICacheDBModel(key: "API-Schedule", syncData: response.body);

        await APICacheManager().addCacheData(cacheDBModel);

        List jsonResponse = json.decode(response.body);
        var resp =
            jsonResponse.map((day) => new dayTable.fromJson(day)).toList();
        processNotification(resp);
        return resp;
      } else {
        throw Exception('Failed to load RemCards');
      }
    } else {
      var cacheData = await APICacheManager().getCacheData("API-Schedule");
      List jsonResponse = json.decode(cacheData.syncData);
      return jsonResponse.map((day) => new dayTable.fromJson(day)).toList();
    }
  }

  //1 day
  List eventTableBuilder(dayTable daytbl) {
    //convert to eventtable
    List<TableEvent> a = [];
    if (daytbl.data != null) {
      daytbl.data.forEach((element) {
        eventTable tbe = eventTable.fromJson(daytbl.day, element);
        a.add(tbe.convert(edit));
      });
      return a;
    } else {
      return [];
    }
  }

  List<LaneEvents> _buildLaneEvents(double width) {
    List<LaneEvents> list = [];
    if (dayTableList.isNotEmpty) {
      dayTableList.forEach((element) {
        list.add(LaneEvents(
            lane: Lane(
                name: numToDay[element.day].substring(0,4).toUpperCase() ??'N/A',
                width: (width / 8),
                textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
            events: eventTableBuilder(element)));
      });
      return list;
    } else {
      return ScheduleHeader(width);
    }
  }
}
