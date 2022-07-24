import 'dart:async';
import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:remcards/main.dart';
import 'package:remcards/pages/editcard.dart';
import 'package:remcards/pages/increment.dart';
import 'package:remcards/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/AppBar.dart';

class remCard {
  final String id;
  final String subjcode;
  final String tskdesc;
  final String tskdate;
  final int tsklvl;
  final int tskstat;

  remCard(
      {this.id,
      this.subjcode,
      this.tskdesc,
      this.tskdate,
      this.tsklvl,
      this.tskstat});

  factory remCard.fromJson(Map<String, dynamic> json) {
    return remCard(
        id: json['_id'],
        subjcode: json['subjcode'],
        tskdesc: json['tskdesc'],
        tskdate: json['tskdate'],
        tsklvl: json['tsklvl'],
        tskstat: json['tskstat']);
  }
}

//============ custom widget ================================

Icon icon(int tskstat) {
  switch (tskstat) {
    case 0:
      return Icon(Icons.adjust_rounded, color: Colors.white);
      break;
    case 1:
      return Icon(Icons.double_arrow_rounded, color: Colors.white);
      break;
    case 2:
      return Icon(Icons.history_toggle_off_rounded, color: Colors.white);
      break;
    case 3:
      return Icon(Icons.stars_rounded, color: Colors.white);
      break;
    case 4:
      return Icon(Icons.check_circle_rounded, color: Colors.white);
      break;
    default:
      return Icon(Icons.adjust_rounded, color: Colors.white);
      break;
  }
}

Color color(int tsklvl) {
  switch (tsklvl) {
    case 0:
      return Color(0xFF2980b9);
      break;
    case 1:
      return Color(0xFFf1c40f);
      break;
    case 2:
      return Color(0xFFe74c3c);
      break;
    default:
      return Color(0xFF2980b9);
      break;
  }
}

//======================= test ===========

class cardBuilder2 extends StatefulWidget {
  final bool isRefresh;

  const cardBuilder2({Key key, this.isRefresh = false}) : super(key: key);

  static _cardBuilder2State of(BuildContext context) =>
      context.findAncestorStateOfType<_cardBuilder2State>();
  @override
  _cardBuilder2State createState() => new _cardBuilder2State();
}

class _cardBuilder2State extends State<cardBuilder2> {
  StreamController _cardController;
  bool isUpdated = false;
  bool fetcherror = false;
  bool unauthorized = false;
  refresh() => _refresh();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  int count = 1;

  Future fetchPost([howMany = 5]) async {
    var cacheExists = await APICacheManager().isAPICacheKeyExist("API-Cards");
    if (!cacheExists) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("token");
      Map<String, String> headers = {
        'Accept': '*/*',
        "Access-Control_Allow_Origin": "*",
        "Content-Type": "application/json",
        "x-access-token": token,
      };
      final response = await http.get(Uri.parse(cardsURI), headers: headers);

      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel =
            new APICacheDBModel(key: "API-Cards", syncData: response.body);

        await APICacheManager().addCacheData(cacheDBModel);

        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((card) => new remCard.fromJson(card)).toList();
      } else if (response.statusCode == 401) {
        sharedPreferences.clear();
        sharedPreferences.commit();
        setState(() {
          unauthorized = true;
        });
      } else {
        setState(() {
          fetcherror = true;
        });
        throw Exception('Failed to load RemCards');
      }
    } else {
      var cacheData = await APICacheManager().getCacheData("API-Cards");

      List jsonResponse = json.decode(cacheData.syncData);
      return jsonResponse.map((card) => new remCard.fromJson(card)).toList();
    }
  }

  loadPosts() async {
    fetchPost().then((res) async {
      _cardController.add(res);
      return res;
    });
  }

  showSnack(String message) {
    return scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _refresh() {
    setState(() {
      _handleRefresh();
    });
  }

  Future<Null> _handleRefresh() async {
    count++;
    print("Refresh: ${count}");
    APICacheManager().deleteCache("API-Cards");
    fetchPost(count * 5).then((res) async {
      _cardController.add(res);
      return null;
    });
  }

  @override
  void initState() {
    super.initState();
    _cardController = new StreamController();
    loadPosts();
    if (widget.isRefresh) {
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: rcAppBarActions("All RemCards", <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            iconSize: 15,
            onPressed: _refresh,
          )
        ]),
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Container(
          padding: EdgeInsets.only(left: 10.0, right: 10.0),
          child: StreamBuilder(
            stream: _cardController.stream,
            builder: (context, snapshot) {
              if ((snapshot.hasData) && ((snapshot.data).isEmpty)) {
                return Center(
                    child: Text(
                        "You have no RemCards yet. Start by adding one!",
                        overflow: TextOverflow.clip,
                        maxLines: 2,
                        style: TextStyle(fontFamily: 'Montserrat')));
              } else if (snapshot.hasData) {
                List<remCard> data = snapshot.data;
                return _cardBuilder(data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text("${snapshot.error}"));
              } else if (fetcherror) {
                return Center(
                    child: Text("Can't load RemCards at the moment."));
              } else if (unauthorized) {
                print("unauthorized!");
                Get.snackbar("Unauthorized", "Try logging back in...");
                Get.offAll(LoginPage());
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ));
  }

  Widget _card(String id, String subjcode, String tskdesc, String tskdate,
      int tsklvl, int tskstat, BuildContext context) {
    tskstat = tskstat % 5;
    return Slidable(
      key: const ValueKey(0),
      startActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => {delcard(id), refresh()},
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),
      child: Card(
        elevation: 2,
        child: InkWell(
            child: ClipPath(
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tskdesc,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700)),
                          Text(subjcode,
                              style: TextStyle(fontFamily: 'Montserrat')),
                          Text(tskdate,
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w300))
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          incstat(id, tskstat);
                          cardBuilder2.of(context).refresh();
                        },
                        child: icon(tskstat),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(CircleBorder()),
                          padding: MaterialStateProperty.all(EdgeInsets.all(5)),
                          backgroundColor: MaterialStateProperty.all(
                              color(tsklvl)), // <-- Button color
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  )),
              clipper: ShapeBorderClipper(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => editCardForm(
                        id: id,
                        subjcode: subjcode,
                        tskdesc: tskdesc,
                        tskdate: tskdate,
                        tsklvl: tsklvl,
                        tskstat: tskstat,
                        callback: refresh),
                  ));
            }),
      ),
    );
  }

  ListView _cardBuilder(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return _card(
              data[index].id,
              data[index].subjcode,
              data[index].tskdesc,
              data[index].tskdate,
              data[index].tsklvl,
              data[index].tskstat,
              context);
        });
  }
}
