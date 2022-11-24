import 'package:flutter/material.dart';

ToggleButtons dayPicker(
    {List<bool> isSelected, Function setState, Function selectDay}) {
  return ToggleButtons(
      children: <Widget>[
        Text("SUN", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("MON", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("TUE", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("WED", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("THU", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("FRI", style: TextStyle(fontSize: 10, color: Colors.brown[600])),
        Text("SAT", style: TextStyle(fontSize: 10, color: Colors.brown[600]))
      ],
      isSelected: isSelected,
      renderBorder: false,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      fillColor: Colors.amberAccent[100],
      onPressed: (int index) {
        setState(() {
          isSelected[index] = !isSelected[index];
          selectDay(index);
        });
      });
}
