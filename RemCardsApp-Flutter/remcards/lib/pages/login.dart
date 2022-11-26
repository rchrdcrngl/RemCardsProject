import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/pages/components/RoundedTextField.dart';
import 'package:remcards/pages/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import '../main.dart';
import '../const.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  var errorMsg;
  final TextEditingController usernameController = new TextEditingController();
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
                    child: Text("Welcome Back to RemCards!",
                        style: TextStyle(
                            color: Colors.teal[600],
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 24)),
                  ),
                  SizedBox(height: 30.0),
                  RoundedTextField("Username", Colors.blueGrey[900],
                      Colors.blueGrey[200], usernameController, false, 12),
                  SizedBox(height: 20.0),
                  RoundedTextField("Password", Colors.blueGrey[900],
                      Colors.blueGrey[200], passwordController, true, 12),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      print("Login pressed");
                      setState(() {
                        _isLoading = true;
                      });
                      signIn(usernameController.text, passwordController.text);
                      //test();
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.teal[600]),
                        elevation: MaterialStateProperty.all(0)),
                    child: Text("Login",
                        style: TextStyle(
                            fontFamily: 'Montserrat', color: Colors.white)),
                  ),
                  errorMsg == null
                      ? Container()
                      : Text(
                          "${errorMsg}",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Not have an account? Create one...',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.blueAccent,
                      fontSize: 10,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => RegisterPage());
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple),
                        elevation: MaterialStateProperty.all(0)),
                    child: Text("Register",
                        style: TextStyle(
                            fontFamily: 'Montserrat', color: Colors.white)),
                  ),
                ],
              ),
      )),
    );
  }

  signIn(String username, pass) async {
    print("signin");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'username': username, 'password': pass};
    var jsonResponse;
    Map<String, String> headers = {
      'Accept': '*/*',
      "Access-Control_Allow_Origin": "*",
      "Content-Type": "application/json"
    };
    var response = await http.post(Uri.parse(loginURI),
        headers: headers, body: jsonEncode(data));
    print("DEBUG: login-post");
    print(response);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['accessToken']);
        sharedPreferences.setString("uname", username);
        sharedPreferences.setBool("isProcessed", false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      errorMsg = response.body;
      print("The error message is: ${response.body}");
    }
  }
}
