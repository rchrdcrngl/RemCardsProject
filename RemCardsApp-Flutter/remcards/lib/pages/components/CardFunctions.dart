import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';

incrementStatus(String id, int tskstat) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };
  Map update = {"tskstat": ++tskstat};
  print(tskstat);
  var response = await http.post(Uri.parse(cardsURI + "/" + id),
      headers: headers, body: jsonEncode(update));
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception('Failed to load jobs from API');
  }
}

deleteCard(String id) async{
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };
  var response = await http.delete(Uri.parse(cardsURI + "/" + id),
      headers: headers);
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception('Failed to load jobs from API');
  }
}