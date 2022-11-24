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