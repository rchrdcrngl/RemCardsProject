import 'package:flutter/material.dart';

AppBar rcAppBar(String text) {
  return AppBar(
    elevation: 0.0,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    title: Text(text,
        style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700)),
  );
}

AppBar rcAppBarActions(String text, List<Widget> actions) {
  return AppBar(
    elevation: 0.0,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    actions: actions,
    title: Text(text,
        style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700)),
  );
}
