import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:remcards/components/notifications.dart';
import 'package:remcards/pages/components/UserFunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remcards/pages/components/AppBar.dart';
import 'login.dart';

class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}

logout() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
  sharedPreferences.commit();
  APICacheManager().deleteCache("API-Cards");
  APICacheManager().deleteCache("API-Schedule");
  cancelScheduledNotifications();
}

class _Settings extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: rcAppBar("Settings"),
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: [
                ElevatedButton(
                    onPressed: () {
                      logout();
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (BuildContext context) => LoginPage()),
                          (Route<dynamic> route) => false);
                    },
                    child: Text("Logout")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      clearRemCards();
                    },
                    child: Text("Clear All RemCards")),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      clearSchedule();
                    },
                    child: Text("Clear Schedule"))
              ],
            )));
  }
}
