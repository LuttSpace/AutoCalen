import 'package:autocalen/models/Schedule.dart';
import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/widgets/DayDialogWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TagCalendar extends StatefulWidget{
  Tag _tag;
  TagCalendar(this._tag);
  @override
  _TagCalendarState createState() => _TagCalendarState();
}

class _TagCalendarState extends State<TagCalendar> {
  var userProvider;
  // 캘린더 데이터
  List<Schedule> schedules = <Schedule>[];
  //appbar
  String _monthName ='';
  String _yearName='';
  //Calendar Controller
  CalendarController _calendarController;
  // 선택한 날짜에 등록된 일정 있는지
  bool isEmpty = true;
  DateTime _date;
  void changeAppBarDateView(ViewChangedDetails viewChangedDetails){
    //앱바에 년월 바꾸기
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) {
      setState(() {
        print('!!!!!!!!!!!!!!!! setstate !!!!!!!!!!!!!!!!!!!!!');
        _monthName = DateFormat('MMM','ko').format(viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString();
        _yearName = DateFormat('yyyy').format(viewChangedDetails
            .visibleDates[viewChangedDetails.visibleDates.length ~/ 2]).toString();
      });
    });
  }
  void viewChanged(ViewChangedDetails viewChangedDetails){
    changeAppBarDateView(viewChangedDetails);
    //showTheImage();
  }
  @override
  void initState() {
    print('tag calendar tid ${widget._tag.tid}');
    userProvider = Provider.of<UserData>(context, listen: false);
    _calendarController = CalendarController();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('ko')
      ],
      locale: const Locale('ko'), //기본 언어 설정
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.black
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: ()=> Navigator.of(context).pop(),
          ),
          title: Text(
            '$_yearName년 $_monthName',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18
              ),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: (){
                  showMonthPicker(
                    locale: Locale('ko'),
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime(DateTime.now().year + 10),
                    initialDate: DateTime.now(),
                  ).then((date) {
                    if (date != null) {
                      _calendarController.displayDate=DateTime(date.year,date.month,date.day);
                    }
                  });

                })
          ],
          elevation: 0.0, //입체감 제거
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('UserList').doc(userProvider.getUid()).
                      collection('ScheduleHub').where('tag.tid',isEqualTo: widget._tag.tid).snapshots(), //.where('tag').where('tid',isEqualTo: widget.tid)
            builder: (context, snapshot) {
              if(snapshot.data==null) {
                  print('isEmpty ${snapshot.data}');
                  return Center(child: Text('로딩'));
              }
              else {
                print('snapshot has something');
                schedules.clear();
                snapshot.data.docs.forEach((doc) {
                  print('doc ' + doc.id);
                  schedules.add(new Schedule(doc.id, doc['title'], doc['start'].toDate(), doc['end'].toDate(),
                      new Tag('',doc['tag']['name'], Color(int.parse(doc['tag']['color'].toString().substring(6, 16)))),doc['memo'], doc['isAllDay'],doc['needAlarm'],'')); //''여기에 tid 넣어야함
                });
                return SafeArea(
                  child: SfCalendar(
                      view: CalendarView.month,
                      controller: _calendarController,
                      onViewChanged: viewChanged,
                      todayTextStyle: TextStyle(
                          color: Colors.white, fontSize: 11),
                      headerHeight: 0,
                      monthViewSettings: MonthViewSettings(
                          appointmentDisplayMode: MonthAppointmentDisplayMode
                              .appointment,
                          monthCellStyle: MonthCellStyle(
                              trailingDatesTextStyle: TextStyle(
                                  color: Colors.black26, fontSize: 11),
                              leadingDatesTextStyle: TextStyle(
                                  color: Colors.black26, fontSize: 11),
                              textStyle: TextStyle(
                                color: Colors.black, fontSize: 11,)
                          )
                      ),
                      selectionDecoration: BoxDecoration(
                          color: Colors.transparent
                      ),
                      dataSource: ScheduleDataSource(schedules),
                      onTap: (details) {
                        if (details.targetElement ==
                            CalendarElement.calendarCell) {
                          _date = details.date;
                          // 선택한 날짜에 일정이 있는 경우
                          if (details.appointments.length > 0)
                            isEmpty = false;
                          // 선택한 날짜에 일정이 없는 경우
                          else
                            isEmpty = true;
                          showDialog(
                              context: context,
                              builder: (context) {
                                return ShowDayDialog(false,_date, isEmpty, details);}
                          );
                        }
                      }
                  ),
                );
              }
            }
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: widget._tag.getTagColor(),
          foregroundColor: widget._tag.getTagColor().computeLuminance()>0.5? Colors.black : Colors.white, //expensive with computLuminance 생각해봐야
          label: Text(widget._tag.getTagName()),
        ),
      ),
    );
  }

}