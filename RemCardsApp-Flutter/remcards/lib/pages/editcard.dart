import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/AppBar.dart';
import 'components/roundedtextfield.dart';

const Map<String, int> tskLevelMap = {'Normal':0, 'Needs Action': 1, 'Urgent': 2};

class editCardForm extends StatefulWidget {
  final String id;
  final String subjcode;
  final String tskdesc;
  final String tskdate;
  final int tsklvl;
  final int tskstat;
  final Function callback;

  //editCardForm(this.id, this.subjcode, this.tskdesc, this.tskdate, this.tsklvl,
  //    this.tskstat);

  const editCardForm(
      {Key key,
      this.id,
      this.subjcode,
      this.tskdesc,
      this.tskdate,
      this.tsklvl,
      this.tskstat,
      this.callback})
      : super(key: key);

  @override
  _editCardForm createState() => _editCardForm();
}

class _editCardForm extends State<editCardForm> {
  DateTime date;

  Future<Null> _selectDate() async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2050));
    if (picked != null && picked != date) {
      setState(() {
        taskDate.text = picked.month.toString() +
            "/" +
            picked.day.toString() +
            "/" +
            picked.year.toString();
        date = picked;
      });
    }
    return null;
  }

  @override
  void initState() {
    subjectCode = new TextEditingController(text: widget.subjcode);
    taskDesc = new TextEditingController(text: widget.tskdesc);
    taskDate = new TextEditingController(text: widget.tskdate);
    taskLevel = new TextEditingController(text: (widget.tsklvl).toString());
    taskStat = new TextEditingController(text: (widget.tskstat).toString());
    var dateParsed = (widget.tskdate).split("/");
    date = new DateTime(int.parse(dateParsed[2]), int.parse(dateParsed[0]),
        int.parse(dateParsed[1]));
    switch (widget.tsklvl) {
      case 0:
        dropdownvalue = "Normal";
        break;
      case 1:
        dropdownvalue = "Needs Action";
        break;
      case 2:
        dropdownvalue = "Urgent";
        break;
      default:
        dropdownvalue = "Normal";
    }
  }

  bool _isLoading = false;
  var errorMsg;
  TextEditingController subjectCode;
  TextEditingController taskDesc;
  TextEditingController taskDate;
  TextEditingController taskLevel;
  TextEditingController taskStat;
  String dropdownvalue = "Normal";

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar("Edit Card"),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Text("   Subject Code",
                      style: TextStyle(
                          color: Colors.deepOrange[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  RoundedTextField("Subject Code", Colors.deepOrange[900],
                      Colors.orange[50], subjectCode, false, 12),
                  SizedBox(height: 15.0),
                  Text("   Task Description",
                      style: TextStyle(
                          color: Colors.deepOrange[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  RoundedTextField("Task Description", Colors.deepOrange[900],
                      Colors.orange[50], taskDesc, false, 12),
                  SizedBox(height: 15.0),
                  Text("   Task Date",
                      style: TextStyle(
                          color: Colors.deepOrange[900], fontSize: 10)),
                  SizedBox(height: 5.0),
                  RoundedTextFieldTap("Task Date", Colors.deepOrange[900],
                      Colors.orange[50], taskDate, false, 12, _selectDate),
                  SizedBox(height: 20.0),
                  DropdownButton<String>(
                    value: dropdownvalue,
                    isExpanded: true,
                    iconSize: 12,
                    elevation: 16,
                    style: const TextStyle(
                        color: Colors.orangeAccent, fontSize: 12),
                    underline: Container(
                      height: 2,
                      color: Colors.orangeAccent,
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        dropdownvalue = newValue;
                        print(dropdownvalue);
                      });
                    },
                    items: <String>['Normal', 'Needs Action', 'Urgent']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                      onPressed: () {
                        editCard(widget.id, subjectCode.text, taskDesc.text,
                            taskDate.text, dropdownvalue, context);
                        // cardBuilder2.of(context).refresh();
                        Get.back();
                        widget.callback();
                        //Get.off(() => MainPage());
                      },
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lime[100]),
                          elevation: MaterialStateProperty.all(0)),
                      child: Text("Edit Card",
                          style: TextStyle(color: Colors.lime[900]))),
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

editCard(String id, String subjcode, String tskdesc, String tskdate,
    String tsklvl, BuildContext context) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  int tsklvl_int = tskLevelMap[tsklvl] ?? 0;
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };

  Map data = {
    'subjcode': subjcode,
    'tskdesc': tskdesc,
    'tskdate': tskdate,
    'tsklvl': tsklvl_int
  };
  var response = await http.post(Uri.parse(cardsURI + "/" + id),
      headers: headers, body: jsonEncode(data));
  if (response.statusCode == 204) {
    print("Successful");
  } else {
    print("Error");
  }
}
