
import 'package:remcards/pages/components/RequestHeader.dart';
import 'package:http/http.dart' as http;
import '../../const.dart';

clearRemCards() async{
  final headers = await getRequestHeaders();
  var response = await http.delete(Uri.parse(cardsURI),
      headers: headers);
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception('Failed to clear RemCards');
  }
}

clearSchedule() async{
  final headers = await getRequestHeaders();
  var response = await http.delete(Uri.parse(schedURI),
      headers: headers);
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception('Failed to clear RemCards');
  }
}

deleteAccount() async{
  final headers = await getRequestHeaders();
  var response = await http.delete(Uri.parse(profileURI),
      headers: headers);
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    throw Exception('Failed to clear RemCards');
  }
}