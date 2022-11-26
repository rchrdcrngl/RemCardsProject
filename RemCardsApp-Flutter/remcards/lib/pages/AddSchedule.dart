import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:remcards/pages/components/DayPicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/AppBar.dart';
import 'components/RoundedTextField.dart';

class addSchedForm extends StatefulWidget {
  final Function refresh;

  const addSchedForm({Key key, this.refresh}) : super(key: key);
  @override
  _addSchedForm createState() => _addSchedForm();
}

class _addSchedForm extends State<addSchedForm> {
  TimeOfDay _startTime;
  TimeOfDay _endTime;
  List<int> daySelected;
  @override
  void initState() {
    super.initState();
    _startTime =
        TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
    _endTime =
        TimeOfDay(hour: (DateTime.now().hour + 1), minute: DateTime.now().hour);
    subject = new TextEditingController();
    timestart = new TextEditingController();
    timefinished = new TextEditingController();
    daySelected = [];
    print(daySelected);
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
  TextEditingController dayfrm = new TextEditingController();
  List<bool> _isSelected = [false, false, false, false, false, false, false];

  selectDay(int index) {
    var dayVal = index == 7? 0 : index;
    _isSelected[index] ? daySelected.add(dayVal) : daySelected.remove(dayVal);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar("Add Schedule"),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                          child: ClipRRect(
                              child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: dayPicker(
                          isSelected: _isSelected,
                          setState: setState,
                          selectDay: selectDay
                        ))))
                    ],
                  ),
                  SizedBox(height: 25.0),
                  Text("   Subject Name",
                      style: TextStyle(color: Colors.brown[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  RoundedTextField("Subject Name", Colors.brown[900],
                      Colors.brown[100], subject, false, 12),
                  SizedBox(height: 15.0),
                  Text("   Start Time",
                      style: TextStyle(color: Colors.brown[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  TextFormField(
                      controller: timestart,
                      onTap: _selectStartTime,
                      style: TextStyle(color: Colors.brown[900], fontSize: 12),
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
                              color: Colors.brown[900].withOpacity(0.5)),
                          fillColor: Colors.brown[100])),
                  SizedBox(height: 15.0),
                  Text("   Finish Time",
                      style: TextStyle(color: Colors.brown[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  TextFormField(
                      controller: timefinished,
                      onTap: _selectFinishTime,
                      style: TextStyle(color: Colors.brown[900], fontSize: 12),
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
                              color: Colors.brown[900].withOpacity(0.5)),
                          fillColor: Colors.brown[100])),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                      onPressed: () {
                        addSched(daySelected, subject.text, timestart.text,
                            timefinished.text);
                        Get.back();
                        widget.refresh();
                        //Get.off(() => MainPage(pageIdx: 1));
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.amberAccent[100]),
                          elevation: MaterialStateProperty.all(0)),
                      child: Text("Add Schedule",
                          style: TextStyle(color: Colors.brown[600]))),
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

addSched(List<int> day, String title, String start, String finish) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };

  day.forEach((element) async {
    Map data = {"subject": title, "startTime": start, "endTime": finish};
    var response = await http.post(Uri.parse('${schedURI}/${element}'),
        headers: headers, body: jsonEncode(data));
    if (response.statusCode == 200) {
      print("Successful");
    } else {
      print("Error");
    }
  });
}
