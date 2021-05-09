import 'dart:io';

import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/Schedule.dart';
import 'package:autocalen/pages/LoginPage.dart';
import 'package:autocalen/pages/SettingPage.dart';
import 'package:autocalen/pages/SortedListByTagPage.dart';
import 'package:autocalen/pages/SplashScreen.dart';
import 'package:autocalen/pages/TagSettingPage.dart';
import 'package:autocalen/widgets/AddScheduleFAB.dart';
import 'package:autocalen/widgets/DayDialogWidget.dart';
import 'package:autocalen/widgets/DrawerWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() async {
  print('======================= void main 시작 ! ==================================');
  WidgetsFlutterBinding.ensureInitialized();
  print('======================= WidgetsFlutterBinding.. 완료 ! ====================');
  await Firebase.initializeApp();
  print('======================= Firebase initializeApp().. 완료 ! =================');
  runApp(MainPage());
}

class MainPage extends StatelessWidget{
  List<Schedule> schedules = [];
  @override
  Widget build(BuildContext context) {
    print('=======================Main Page Build==============================');
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserData>(create: (_) => UserData()),
          //Provider<String>.value(value: "Park")
        ],
        child: MaterialApp(
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
          initialRoute: '/splash',
          routes: {
            '/home' :(context)=> HomePage(),
            '/tagSetting':(context)=>TagSetting(),
            '/sortedListByTag':(context)=>SortedListByTag(),
            '/login': (context)=>Login(),
            '/splash': (context) => SplashScreen(),
            '/setting': (context) => Setting(),
          },
        ),
    );
  }
}

// 처음 인지 체크함
bool isItFirstData = true;
int authCalled = 0;
var userAuth = FirebaseAuth.instance;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('=======================Home Page Build==============================');
    return StreamBuilder(
        stream: userAuth.authStateChanges(),//FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          print('auth ${++authCalled}');
          // 처음 데이터인가? 스피너를 돌리기 (로그인으로 인식할 때까지)
          if (isItFirstData) {
            print('auth 로딩중');
            isItFirstData=false;
            return Scaffold(
                resizeToAvoidBottomInset: false,
                body: Center(
                  child: CircularProgressIndicator(),
                )
            );
          } else {
            if (!snapshot.hasData) {
              print('auth 데이타 없음');
              return Login();
            }
            else {
              print('query uid ${userAuth.currentUser.uid}');
              return CalendarPage();
            }
          }
        }
    );
  }
}

//Calendar

class CalendarPage extends StatefulWidget{
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // bool loginState = false; // 로그인 상태 확인
  //appbar
  String _monthName ='';
  String _yearName='';

  // 선택한 날짜에 등록된 일정 있는지
  bool isEmpty = true;
  DateTime _date;

  //Calendar Controller
  CalendarController _calendarController;
  // 캘린더 데이터
  List<Schedule> schedules = <Schedule>[];

  @override
  void initState(){
    _calendarController = CalendarController();
    super.initState();
  }

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

  ScheduleDataSource getCalendarDataSource() {
    // 스케줄 데이터 추가
    print('real '+schedules.length.toString());
    return ScheduleDataSource(schedules);
  }

  // 처음 인지 체크함
  bool isItFirstData = true;

  int snapCalled=0;
  int buildCalled =0;
  @override
  Widget build(BuildContext context) {
    print('=======================Calendar Page Build==========================');
    print('빌드 횟수!!! ${++buildCalled}');
    final userProvider = Provider.of<UserData>(context, listen: false);
    print('userProvider needAlarms ${userProvider.getNeedAlarms()}');
    if(userProvider.getUid()!='' &&userProvider.getUid()!=null ){
      print('main page~~~~~ '+ userProvider.getEmail());
    }
    else{
      print('main page~~~~~ ');
    }
    var userAuth = FirebaseAuth.instance;
    return Scaffold(
        appBar: AppBar(
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
        drawer: ShowDrawer(),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('UserList').doc(userAuth.currentUser.uid).collection('ScheduleHub').snapshots(),
          builder: (context, snapshot) {
            print('snap ${++snapCalled}');
            if(snapshot.data==null) {
              print('isEmpty ${snapshot.data}');
              return Center(child: SpinKitFadingCircle(
                color: Colors.black,
              ));
            }
            else {
              print('start calling data on ${snapCalled} ');
              schedules.clear();
              snapshot.data.docs.forEach((doc) {
                print('doc ' + doc.id);

                schedules.add(new Schedule(doc.id, doc['title'], doc['start'].toDate(), doc['end'].toDate(),
                    new Tag(doc['tag']['tid'],doc['tag']['name'], Color(int.parse(doc['tag']['color'].toString().substring(6, 16)))),doc['memo'], doc['isAllDay'],doc['needAlarm']));
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
                    dataSource: getCalendarDataSource(),
                    //firestore에서 데이터 가져오기
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
                              return ShowDayDialog(true,_date, isEmpty, details);}
                        );
                      }
                    }
                ),
              );
            }
          },
        ),
        floatingActionButton:  AddScheduleFAB(true)
    );
  }
}