import 'package:shared_preferences/shared_preferences.dart';

Future<void> invalidateSession() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
  // ignore: deprecated_member_use
  sharedPreferences.commit();
}
