import 'dart:core';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}

String timeToString(int hour, int min) {
  if (hour == 0) {
    return 12.toString() + ":" + appendZero(min) + " AM";
  } else if (hour < 12) {
    return hour.toString() + ":" + appendZero(min) + " AM";
  } else {
    return (hour - 12).toString() + ":" + appendZero(min) + " PM";
  }
}

String appendZero(int num) {
  if (num < 10)
    return "0" + num.toString();
  else
    return num.toString();
}

List advancedTime(int hour, int min, int advance) {
  int newHour = hour;
  int newMin = (min - advance) % 60;
  if ((min - advance) < 0) newHour = (hour - 1) % 24;
  return [newHour, newMin];
}
