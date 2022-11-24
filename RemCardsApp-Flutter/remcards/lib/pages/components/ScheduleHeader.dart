import 'package:flutter/material.dart';
import 'package:flutter_timetable_view/flutter_timetable_view.dart';

List<LaneEvents> ScheduleHeader(width) {
  return [
        LaneEvents(
            lane: Lane(
                name: 'SUN',
                width: (width / 8),
                textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
            events: []),
        LaneEvents(
            lane: Lane(
                name: 'MON',
                width: (width / 8),
                textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
            events: []),
        LaneEvents(
          lane: Lane(
              name: 'TUE',
              width: (width / 8),
              textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
          events: [],
        ),
        LaneEvents(
          lane: Lane(
              name: 'WED',
              width: (width / 8),
              textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
          events: [],
        ),
        LaneEvents(
          lane: Lane(
              name: 'THURS',
              width: (width / 8),
              textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
          events: [],
        ),
        LaneEvents(
          lane: Lane(
              name: 'FRI',
              width: (width / 8),
              textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
          events: [],
        ),
        LaneEvents(
          lane: Lane(
              name: 'SAT',
              width: (width / 8),
              textStyle: TextStyle(color: Colors.brown, fontSize: 10)),
          events: [],
        ),
      ];
}