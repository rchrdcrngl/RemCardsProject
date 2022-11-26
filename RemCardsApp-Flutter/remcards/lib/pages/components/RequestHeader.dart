import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, String>> getRequestHeaders() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String token = sharedPreferences.getString("token");
  Map<String, String> headers = {
    'Accept': '*/*',
    "Access-Control_Allow_Origin": "*",
    "Content-Type": "application/json",
    "x-access-token": token,
  };
  return headers;
}
