import 'dart:io';

import 'package:autocalen/models/schedule.dart';
import 'package:autocalen/pages/LoginPage.dart';
import 'package:autocalen/pages/TagSettingPage.dart';
import 'package:autocalen/widgets/DayDialogWidget.dart';
import 'package:autocalen/widgets/DrawerWidget.dart';
import 'package:autocalen/widgets/MainFABWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Center(
            child: Text("firebase load fail"),
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
          return MaterialApp(
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
            initialRoute: '/',
            routes: {
              '/' :(context)=> CalendarPage(),
              '/tagSetting':(context)=>TagSetting(),
              '/login': (context)=>Login(),
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

//Calendar

class CalendarPage extends StatefulWidget{
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool loginState = false; // 로그인 상태 확인
  
  //appbar
  String _monthName ='';
  String _yearName='';

  // 선택한 날짜에 등록된 일정 있는지
  bool isEmpty = true;
  String _dateText ='';

  //Calendar Controller
  CalendarController _calendarController;

  @override
  void initState(){
    _dateText = '';
    _calendarController = CalendarController();
    super.initState();
  }

  void changeAppBarDateView(ViewChangedDetails viewChangedDetails){
    //앱바에 년월 바꾸기
    SchedulerBinding.instance
        .addPostFrameCallback((timeStamp) {
      setState(() {
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

  ScheduleDataSource getCalendarDataSource() {
    // 스케줄 데이터 추가
    List<Schedule> schedules = <Schedule>[];

    final DateTime today = DateTime.now(); // 오늘 날짜
    final DateTime startTime = DateTime(today.year, today.month, today.day, 9, 0, 0); // 시작 날짜 (년, 월, 일, 시, 분, 초)
    final DateTime startTime2 = DateTime(today.year, today.month, today.day); // 시작 날짜 (년, 월, 일, 시, 분, 초)
    final DateTime endTime = startTime.add(const Duration(hours: 2)); // 종료 날짜
    final DateTime endTime2 = startTime2.add(const Duration(days: 3)).subtract(const Duration(seconds: 1)); // 3일동안
    final DateTime endTime3 = DateTime(today.year, today.month, today.day+1);

    schedules.add(Schedule(
        '제주도 여행', DateTime(2021,4,10), DateTime(2021,4,10).add(Duration(days: 2)), const Color(0xFF0F8644), false));
    schedules.add(Schedule(
        '졸작 회의', startTime2, startTime2, const Color(0xFFFF32e2), false));
    schedules.add(Schedule(
        '만우절', DateTime(2021,4,1), DateTime(2021,4,1) , const Color(0xFF0032e2), false));
    schedules.add(Schedule(
        '미나리 보러가기', DateTime(2021,4,3), DateTime(2021,4,3), const Color(
        0xFFBD1B5C), false));
    schedules.add(Schedule(
        '샤이니 문명특급', startTime2, startTime2, Color(0xFF6341BD), false));
    schedules.add(Schedule(
        '샤이니 콘서트', DateTime(2021,4,25), DateTime(2021,4,25), Color(0xFF6341BD), false));
    return ScheduleDataSource(schedules);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: loginState? AppBar(
          title: Center(
              child: TextButton(
                onPressed: (){
                  print(_yearName+'년 '+_monthName);
                },
                child: Text('$_yearName년 $_monthName'),
                style: TextButton.styleFrom(
                  primary: Colors.black,
                  padding: EdgeInsets.all(0),
                  textStyle: TextStyle(
                      fontSize: 19
                  ),
                ),
              ),
          ),
          titleTextStyle: TextStyle(
            fontStyle: FontStyle.normal,
            fontSize: 5
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: (){
                  showMonthPicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 10),
                    lastDate: DateTime(DateTime.now().year + 10),
                    initialDate: DateTime.now(),
                  ).then((date) {
                    if (date != null) {
                      setState(() {
                        print("selected "+date.toString());
                        //selectedDate = date;
                        _calendarController.displayDate=DateTime(date.year,date.month,date.day);
                      });
                    }
                  });

                })
          ],
          elevation: 0.0, //입체감 제거
        ): null,
        drawer: ShowDrawer(),
        body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
            if(!snapshot.hasData){
              if(loginState){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    loginState= false;
                  });
                });
              }
              return Login();
            }
            else{
              loginState = true;
              return SafeArea(
                child: SfCalendar(
                    view: CalendarView.month,
                    controller: _calendarController,
                    onViewChanged: viewChanged,
                    todayTextStyle: TextStyle(color: Colors.white,fontSize: 11),
                    headerHeight: 0,
                    monthViewSettings: MonthViewSettings(
                        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                        monthCellStyle: MonthCellStyle(
                            trailingDatesTextStyle: TextStyle(color: Colors.black26,fontSize: 11),
                            leadingDatesTextStyle: TextStyle(color:Colors.black26,fontSize: 11),
                            textStyle: TextStyle(color: Colors.black,fontSize: 11,)
                        )
                    ),
                    selectionDecoration: BoxDecoration(
                        color: Colors.transparent
                    ),
                    dataSource: getCalendarDataSource(),
                    onTap: (details) {
                      if (details.targetElement == CalendarElement.calendarCell) {
                        _dateText = DateFormat('yyyy년 MM월 dd일 (E)', 'ko')
                            .format(details.date)
                            .toString();
                        // 선택한 날짜에 일정이 있는 경우
                        if (details.appointments.length > 0) isEmpty = false;
                        // 선택한 날짜에 일정이 없는 경우
                        else isEmpty = true;
                        showDialog(
                            context:context,
                            builder:(context){
                              return ShowDayDialog(_dateText, isEmpty, details);
                            }
                        );
                      }
                    }
                ),
              );
            }
          }
        ),
        floatingActionButton: loginState? MainFAB(): null
    );
  }
}