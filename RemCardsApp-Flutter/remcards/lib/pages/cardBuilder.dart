import 'dart:async';
import 'dart:convert';
import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:remcards/const.dart';
import 'package:remcards/pages/components/Card.dart';
import 'package:remcards/pages/components/RequestHeader.dart';
import 'package:remcards/pages/components/SessionHandler.dart';
import 'package:remcards/pages/components/CardFunctions.dart';
import 'package:remcards/pages/login.dart';
import 'components/AppBar.dart';
import 'components/RemCard.dart';


//======================= builder ===========
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
  bool fetchError = false;
  bool unauthorized = false;
  refresh() => _refresh();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  int count = 1;

  Future fetchData([howMany = 5]) async {
    var cacheExists = await APICacheManager().isAPICacheKeyExist("API-Cards");
    if (!cacheExists) {
      final headers = await getRequestHeaders();
      final response = await http.get(Uri.parse(cardsURI), headers: headers);

      if (response.statusCode == 200) {
        APICacheDBModel cacheDBModel =
            new APICacheDBModel(key: "API-Cards", syncData: response.body);

        await APICacheManager().addCacheData(cacheDBModel);

        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((card) => new RemCard.fromJson(card)).toList();
      } else if (response.statusCode == 401) {
        invalidateSession();
        setState(() {
          unauthorized = true;
        });
      } else {
        setState(() {
          fetchError = true;
        });
        throw Exception('Failed to load RemCards');
      }
    } else {
      var cacheData = await APICacheManager().getCacheData("API-Cards");

      List jsonResponse = json.decode(cacheData.syncData);
      return jsonResponse.map((card) => new RemCard.fromJson(card)).toList();
    }
  }
  

  parseData() async {
    fetchData().then((res) async {
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
    fetchData(count * 5).then((res) async {
      _cardController.add(res);
      return null;
    });
  }

  @override
  void initState() {
    super.initState();
    _cardController = new StreamController();
    parseData();
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
                List<RemCard> data = snapshot.data;
                return _cardBuilder(data);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text("${snapshot.error}"));
              } else if (fetchError) {
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

  

  ListView _cardBuilder(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return RCard(
                remcard: data[index],
                deleteCard: deleteCard,
                refresh: refresh,
                incrementStatus: incrementStatus,
                context: context,
              );
        });
  }
}
