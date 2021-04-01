import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Schedule {
  /// Creates a schedule class with required details.
  Schedule(this.title, this.startTime, this.endTime, this.tag, this.isAllDay);

  /// Event name which is equivalent to subject property of [Appointment].
  String title; // 일정 제목

  /// From which is equivalent to start time property of [Appointment].
  DateTime startTime; // 시작 날짜, 시간

  /// To which is equivalent to end time property of [Appointment].
  DateTime endTime; // 종료 날짜, 시간

  /// Background which is equivalent to color property of [Appointment].
  Color tag; // 배경색

  /// 일단은 주석,, 나중에
  // String memo; // 메모

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay; // 하루종일 여부
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class ScheduleDataSource extends CalendarDataSource {
  // schedule data source 생성 => 캘린더에 appointment 컬렉션 설정하기 위해 사용
  ScheduleDataSource(List<Schedule> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments[index].title;
  }

  @override
  Color getColor(int index) {
    return appointments[index].tag;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}