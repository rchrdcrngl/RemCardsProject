class DaySchedule {
  final String id;
  final int day;
  final List<dynamic> data;
  const DaySchedule({this.id, this.day, this.data});

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
        id: json["_id"].toString(), day: json["day"], data: json["data"]);
  }

  String toString() {
    return "dayTable: " + id + " " + day.toString() + " " + data.toString();
  }
}