import 'package:intl/intl.dart';

class RemCard {
  String id;
  String subjcode;
  String tskdesc;
  String tskdate;
  int tsklvl;
  int tskstat;

  RemCard(
      {this.id,
      this.subjcode,
      this.tskdesc,
      this.tskdate,
      this.tsklvl,
      this.tskstat});

  factory RemCard.fromJson(Map<String, dynamic> json) {
    return RemCard(
        id: json['_id'],
        subjcode: json['subjcode'],
        tskdesc: json['tskdesc'],
        tskdate:
            DateFormat("M/d/y").format(DateTime.parse(json['tskdate'])) ?? '',
        tsklvl: json['tsklvl'],
        tskstat: json['tskstat']);
  }
}
