import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:remcards/main.dart';
import 'package:remcards/pages/components/RoundedTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/AppBar.dart';

class editSchedForm extends StatefulWidget {
  final String id;
  final int day;
  final String title;
  final int hourStart;
  final int minStart;
  final int hourFinish;
  final int minFinish;
  //final Function refresh;

  editSchedForm(this.day, this.id, this.title, this.hourStart, this.minStart,
      this.hourFinish, this.minFinish);
  @override
  _editSchedForm createState() => _editSchedForm();
}

class _editSchedForm extends State<editSchedForm> {
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay(hour: widget.hourStart, minute: widget.minStart);
    _endTime = TimeOfDay(hour: widget.hourFinish, minute: widget.minFinish);
    subject = new TextEditingController(text: widget.title);
    timestart = new TextEditingController(
        text: widget.hourStart.toString() + ":" + widget.minStart.toString());
    timefinished = new TextEditingController(
        text: widget.hourFinish.toString() + ":" + widget.minFinish.toString());
  }

  Future<Null> _selectStartTime() async {
    print("sst");
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (_startTime != null) {
      setState(() {
        _startTime = newTime;
        timestart.text =
            _startTime.hour.toString() + ":" + _startTime.minute.toString();
      });
    }
    return null;
  }

  Future<Null> _selectFinishTime() async {
    print("sft");
    final TimeOfDay newTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (_endTime != null) {
      setState(() {
        _endTime = newTime;
        timefinished.text =
            _endTime.hour.toString() + ":" + _endTime.minute.toString();
      });
    }
    return null;
  }

  bool _isLoading = false;
  var errorMsg;
  TextEditingController subject;
  TextEditingController timestart;
  TextEditingController timefinished;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar("Edit Schedule"),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Text("   Subject Name",
                      style: TextStyle(color: Colors.lime[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  RoundedTextField("Subject Name", Colors.lime[900],
                      Colors.lime[100], subject, false, 12),
                  SizedBox(height: 15.0),
                  Text("   Start Time",
                      style: TextStyle(color: Colors.lime[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  TextFormField(
                      controller: timestart,
                      onTap: _selectStartTime,
                      style: TextStyle(color: Colors.lime[900], fontSize: 12),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintText: "Start Time",
                          hintStyle: TextStyle(
                              color: Colors.lime[900].withOpacity(0.5)),
                          fillColor: Colors.lime[100])),
                  SizedBox(height: 15.0),
                  Text("   End Time",
                      style: TextStyle(color: Colors.lime[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  TextFormField(
                      controller: timefinished,
                      onTap: _selectFinishTime,
                      style: TextStyle(color: Colors.lime[900], fontSize: 12),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.transparent, width: 0.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 1.0),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          filled: true,
                          hintText: "Finish Time",
                          hintStyle: TextStyle(
                              color: Colors.lime[900].withOpacity(0.5)),
                          fillColor: Colors.lime[100])),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        editSched(widget.day, widget.id, subject.text,
                            timestart.text, timefinished.text);
                        Get.offAll(() => MainPage(pageIdx: 1, sRef: true));
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.teal[100]),
                          elevation: MaterialStateProperty.all(0)),
                      child: Text("Edit Schedule",
                          style: TextStyle(color: Colors.teal[700]))),
                  SizedBox(height: 5.0),
                  ElevatedButton(
                      onPressed: () {
                        deleteSched(widget.id, widget.day);
                        //MainPage.of(context).schedRefresh();
                        //MainPage.of(context).returnAt(1);
                        Get.offAll(() => MainPage(pageIdx: 1, sRef: true));
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red[900]),
                          elevation: MaterialStateProperty.all(0)),
                      child: Text("Delete Schedule",
                          style: TextStyle(color: Colors.white))),
                  errorMsg == null
                      ? Container()
                      : Text(
                          "${errorMsg}",
                        ),
                ],
              ),
      ),
    );
  }
}

editSched(
    int day, String id, String title, String start, String finish) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };

  Map data = {"subject": title, "time": (start + "-" + finish)};
  var response = await http.post(Uri.parse('${schedURI}/${day}/${id}'),
      headers: headers, body: jsonEncode(data));
  if (response.statusCode == 204) {
    print("Successful");
  } else {
    print("Error");
  }
  Get.back();
}

deleteSched(String id, int day) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };

  var response = await http.delete(Uri.parse('${schedURI}/${day}/${id}'),
      headers: headers);
  if (response.statusCode == 204) {
    print("Successful");
  } else {
    print("Error");
  }
}
