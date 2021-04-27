import 'package:autocalen/models/Tag.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Schedule {
  /// Creates a schedule class with required details.
  Schedule(this.sid, this.title, this.start, this.end, this.tag, this.memo, this.isAllDay);

  String sid;
  /// Event name which is equivalent to subject property of [Appointment].
  String title; // 일정 제목

  /// From which is equivalent to start time property of [Appointment].
  DateTime start; // 시작 날짜, 시간

  /// To which is equivalent to end time property of [Appointment].
  DateTime end; // 종료 날짜, 시간

  /// Background which is equivalent to color property of [Appointment].
  Color color;
  Tag tag; // 배경색

  /// 옵션으로.. 메모 없으면 빈 문자열로
  String memo; // 메모

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay; // 하루종일 여부

  setTitle(String _title)=> title =_title;
  void setStart(DateTime s) {this.start=s;}
  void setEnd(DateTime e) {this.end=e;}
  void setTag(Tag t) {this.tag=t;}
  void setMemo(String m) {this.memo = m;}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return {
      'title': title,
      'start': start,
      'end': end,
      'tag': tag.toJson(),
      'memo': memo,
      'isAllDay': isAllDay,
    };
  }



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
    return appointments[index].start;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].end;
  }

  @override
  String getSubject(int index) {
    return appointments[index].title;
  }

  @override
  Tag getTag(int index) {
    return appointments[index].tag;
  }

  @override
  Color getColor(int index){
    return appointments[index].tag.getTagColor();
  }

  @override
  String getNotes(int index){
    return appointments[index].memo;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}