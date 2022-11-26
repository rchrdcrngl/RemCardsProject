import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:remcards/pages/AddCard.dart';
import 'package:remcards/pages/CardBuilder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'pages/Login.dart';
import 'pages/Schedule.dart';
import 'pages/Settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      defaultColor: Colors.teal,
      importance: NotificationImportance.Default,
      channelShowBadge: true, channelDescription: 'Allows RemCard to be on the basic notification channel',
    ),
    NotificationChannel(
      channelKey: 'scheduled_channel',
      channelName: 'Scheduled Notifications',
      defaultColor: Colors.teal,
      importance: NotificationImportance.Default, channelDescription: 'Allows RemCard to create scheduled notifications',
    )
  ]);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    print("Notif Allowed?: " + isAllowed.toString());
    if (!isAllowed)
      AwesomeNotifications().requestPermissionToSendNotifications();
  });
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RemCards",
      theme: ThemeData(
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
          bodyText1: TextStyle(fontSize: 12.0),
        ),
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  final int pageIdx;
  final bool cRef;
  final bool sRef;

  const MainPage(
      {Key key, this.pageIdx = 0, this.cRef = false, this.sRef = false})
      : super(key: key);

  static _MainPageState of(BuildContext context) =>
      context.findAncestorStateOfType<_MainPageState>();

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  SharedPreferences sharedPreferences;

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().createdSink.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loginStatus();
    if (widget.cRef) cardsRefresh();
    if (widget.sRef) schedRefresh();
    returnAt(widget.pageIdx);

    //NOTIFICATION
    AwesomeNotifications().actionStream.listen((notification) {
      if (notification.channelKey == 'basic_channel' && Platform.isIOS) {
        AwesomeNotifications().getGlobalBadgeCounter().then(
              (value) =>
                  AwesomeNotifications().setGlobalBadgeCounter(value - 1),
            );
      }
    });
  }

  returnAt(int idx) {
    _onItemTapped(idx);
  }

  cardsRefresh() {
    setState(() {
      _widgetOptions[0] = cardBuilder2(isRefresh: true);
    });
    print("MAIN: CARDS_REFRESH");
  }

  schedRefresh() {
    setState(() {
      _widgetOptions[1] = SchedulePage(isRefresh: true);
    });
    print("MAIN: SCHEDULE_REFRESH");
  }

  loginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("token"));
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
          (Route<dynamic> route) => false);
    }
  }

  int _selectedIndex = 0;
  List<Widget> _widgetOptions = <Widget>[
    cardBuilder2(),
    SchedulePage(),
    addCardForm(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_day_rounded, size: 20.0),
                  label: 'RemCards',
                  backgroundColor: Colors.purple),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today, size: 20.0),
                  label: 'Schedule',
                  backgroundColor: Colors.orange),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outlined, size: 20.0),
                label: 'Add Card',
                backgroundColor: Colors.green,
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, size: 20.0),
                  label: 'Settings',
                  backgroundColor: Colors.blue),
            ],
            currentIndex: _selectedIndex,
            showSelectedLabels: false,
            backgroundColor: Colors.deepPurple[50],
            onTap: _onItemTapped,
          )),
    );
  }
}
