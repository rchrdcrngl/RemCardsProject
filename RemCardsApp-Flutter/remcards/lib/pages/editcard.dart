import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'components/AppBar.dart';
import 'components/RemCard.dart';
import 'components/RequestHeader.dart';
import 'components/RoundedTextField.dart';

const Map<String, int> tskLevelMapFromString = {'Normal':0, 'Needs Action': 1, 'Urgent': 2};
const Map<int, String> tskLevelMapFromInt = {0:'Normal', 1:'Needs Action', 2:'Urgent'};

class editCardForm extends StatefulWidget {
  final RemCard remcard;
  final Function callback;

  const editCardForm(
      {Key key,
      this.remcard,
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
    subjectCode = new TextEditingController(text: widget.remcard.subjcode);
    taskDesc = new TextEditingController(text: widget.remcard.tskdesc);
    taskDate = new TextEditingController(text: widget.remcard.tskdate);
    taskLevel = new TextEditingController(text: (widget.remcard.tsklvl).toString());
    taskStat = new TextEditingController(text: (widget.remcard.tskstat).toString());
    var dateParsed = (widget.remcard.tskdate).split("/");
    date = new DateTime(int.parse(dateParsed[2]), int.parse(dateParsed[0]),
        int.parse(dateParsed[1]));
    dropdownvalue = tskLevelMapFromInt[widget.remcard.tsklvl] ?? 'Normal';
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
                        editCard(widget.remcard.id, subjectCode.text, taskDesc.text,
                            taskDate.text, dropdownvalue);
                        Get.back();
                        widget.callback();
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
    String tsklvl) async {
  int tsklvl_int = tskLevelMapFromString[tsklvl] ?? 0;
  final headers = await getRequestHeaders();
  Map data = {
    'subjcode': subjcode,
    'tskdesc': tskdesc,
    'tskdate': tskdate,
    'tsklvl': tsklvl_int
  };
  var response = await http.post(Uri.parse('${cardsURI}/${id}'),
      headers: headers, body: jsonEncode(data));
  if (response.statusCode == 204) {
    print("Successful");
  } else {
    print("Error");
  }
}
