import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart';
import 'package:get/get.dart';
import 'components/RoundedTextField.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isLoading = false;
  var errorMsg;
  final TextEditingController usernameController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: Container(
        padding: EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  Center(
                      child: Text("Welcome to RemCards!",
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w700,
                              fontSize: 24))),
                  SizedBox(height: 30.0),
                  RoundedTextField("Username", Colors.blueGrey[900],
                      Colors.blueGrey[200], usernameController, false, 12),
                  SizedBox(height: 20.0),
                  RoundedTextField("Email", Colors.blueGrey[900],
                      Colors.blueGrey[200], emailController, false, 12),
                  SizedBox(height: 20.0),
                  RoundedTextField("Password", Colors.blueGrey[900],
                      Colors.blueGrey[200], passwordController, true, 12),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      Register(usernameController.text, emailController.text,
                          passwordController.text);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.grey[800]),
                        elevation: MaterialStateProperty.all(0)),
                    child: Text("Register",
                        style: TextStyle(
                            fontFamily: 'Montserrat', color: Colors.white70)),
                  ),
                  errorMsg == null
                      ? Container()
                      : Text(
                          "${errorMsg}",
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple),
                        elevation: MaterialStateProperty.all(0)),
                    child: Text("Login",
                        style: TextStyle(
                            fontFamily: 'Montserrat', color: Colors.white70)),
                  )
                ],
              ),
      )),
    );
  }

  Register(String username, email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {
      'username': username,
      'email': email,
      'password': pass,
      'roles': ["user"],
      'data': [],
      'schedule': []
    };
    var jsonResponse;
    Map<String, String> headers = {
      'Accept': '*/*',
      "Access-Control_Allow_Origin": "*",
      "Content-Type": "application/json"
    };
    var response = await http.post(Uri.parse(signupURI),
        headers: headers, body: jsonEncode(data));
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['accessToken']);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      errorMsg = response.body;
      print("The error message is: ${response.body}");
    }
    Get.back();
  }
}
