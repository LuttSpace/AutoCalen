import 'dart:io';

import 'package:autocalen/models/schedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
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
        home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget{
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
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
        'Conference', startTime, endTime, const Color(0xFF0F8644), false));
    schedules.add(Schedule(
        'Meeting', startTime2, endTime2, const Color(0xFFFF32e2), false));
    schedules.add(Schedule(
        'Study', startTime, endTime3, const Color(0xFF0032e2), false));
    schedules.add(Schedule(
        'Play', startTime2, endTime, const Color(0xFFFF0000), false));
    schedules.add(Schedule(
        'Algorithm Study', startTime2, endTime2, const Color(0xFFFFFF00), false));
    return ScheduleDataSource(schedules);
  }

  void calendarTapped(CalendarTapDetails details) {
    // 캘린더 날짜 탭한 경우
    if (details.targetElement == CalendarElement.calendarCell) {
      _dateText = DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(details.date).toString();

      // 선택한 날짜에 일정이 있는 경우
      if (details.appointments.length > 0) isEmpty = false;
      // 선택한 날짜에 일정이 없는 경우
      else isEmpty = true;

      showDialog( // 팝업창 띄우기
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                  padding:EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                  child: new Text('$_dateText')
              ),
              content:Container(
                height: MediaQuery.of(context).size.height*0.45,
                width: MediaQuery.of(context).size.width*0.8,
                child: _buildScheduleListView(context, details),
              ),
              shape: RoundedRectangleBorder( // 모서리 둥글게
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              actions: <Widget>[
              ],
            );
          });
    }
  }

  String subtitleDate(DateTime startTime, DateTime endTime){
    String subtitle;

    // 시작날짜, 종료 날짜 비교
    if(startTime.difference(endTime).inDays==0){ // 시작날짜, 종료날짜가 같으면
      subtitle= DateFormat('MM월 dd일').format(startTime).toString();
    } else{
      subtitle='${DateFormat('MM월 dd일').format(startTime).toString()} - ${DateFormat('MM월 dd일').format(endTime).toString()}';
    }
    return subtitle;
  }

  // 날짜 클릭시 뜨는 팝업창 내부 리스트 뷰 (해당 날짜에 저장된 일정 리스트로 뜨도록..)
  Widget _buildScheduleListView(BuildContext context, CalendarTapDetails details){
    if(isEmpty){ // 일정 없는 경우
      return Container(
          padding: EdgeInsets.symmetric(horizontal:10.0, vertical: 5.0),
          child: Text('등록된 일정이 없습니다'));
    }
    else{
      return ListView.separated(
        itemCount: details.appointments.length,
        itemBuilder: (BuildContext _context, int i){
          return ListTile(
            minLeadingWidth: 10, // leading 부분 최소 넓이
            leading: SizedBox(
              width: 5,
              child: Container(
                  color: details.appointments[i].tag
              ),
            ),
            minVerticalPadding: 4.0, // 각 일정 탭 별 padding 값
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            title: Text(details.appointments[i].title),
            subtitle: Text(subtitleDate(details.appointments[i].startTime, details.appointments[i].endTime)),
            onTap: () {// 일정 탭한 경우
              _showDialogDebug(context, details.appointments[i]);
            },
          );
        },
        separatorBuilder: (context, index) { return Divider(
          height: 0.0, // 구분선 높이 조정
        );},
      );
    }
  }

  void _showDialogDebug(BuildContext context, Schedule schedule) {
    // 디버깅용 팝업창 -> 각 일정 탭 클릭 시
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(child: new Text('각 일정 탭 클릭')),
            content:Container(
              height: MediaQuery.of(context).size.height*0.5,
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('제목 : ${schedule.title}'),
                  Text('시작 날짜 : ${schedule.startTime}'),
                  Text('종료 날짜 : ${schedule.endTime}'),
                  Text('하루 종일 여부 : ${schedule.isAllDay}'),
                  Text('색상 : ${schedule.tag}'),
              ]),
            ),
            shape: RoundedRectangleBorder( // 모서리 둥글게
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            actions: <Widget>[
              new TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: new Text('추가하기'),
                  style: TextButton.styleFrom(primary: Colors.black)
              )],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                arrowColor: Colors.pink,
                accountEmail: Text('98sena@naver.com'),
                accountName: Text('김예리'),
                currentAccountPicture: CircleAvatar(
                  child: Icon(Icons.person,color: Colors.black),
                  backgroundColor: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12
                ),
              ),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('태그 설정'),
                onTap: (){
                  print('태그 설정');
                  Navigator.push(context,MaterialPageRoute(builder: (context)=> TagSetting()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('설정'),
                onTap: (){
                  print('설정');
                },
              ),
            ],
          )
        ),
        body: SafeArea(
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
            onTap: calendarTapped
          ),
        ),
        floatingActionButton: AddImgFAB()
    );
  }
}

//파일 분리 하고 싶음
//tag setting
class Tag{
  String _tagName;
  Color _tagColor;

  Tag(this._tagName,this._tagColor);

  Color getTagColor() {return _tagColor; }
  String getTagName() {return _tagName; }

  void setTagColor(Color color){
    _tagColor=color;
  }
  void setTagName(String name){
    _tagName = name;
  }
}
class TagTile extends StatelessWidget{
  TagTile(this._tag);
  final Tag _tag;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading : ElevatedButton(
                  onPressed: ()=>print('nothing'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(_tag.getTagColor())
                  ),
              ),
      title: Text(_tag._tagName),
    );
  }
}
class TagSetting extends StatefulWidget{
  @override
  _TagSettingState createState() => _TagSettingState();
}

class _TagSettingState extends State<TagSetting> {
  Color _currentColor = Colors.blueAccent;
  Color _pickedColor = Colors.black;
  void pickColor(Color color){
    setState(() {
      _pickedColor = color;
    });
  }
  List<Tag> tags;


  @override
  void initState() {
    tags = [];
    tags.add(new Tag('모임',Colors.deepPurple));
    print('tag길이 '+tags.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.black
        ),
        home: Scaffold(
            appBar: AppBar(
              title: Text('태그 설정'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: ()=> Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.check),
                    onPressed: ()=>Navigator.of(context).pop()
                )
              ],
            ),
            body: Column(
                children: [
                  Container(
                    width : MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                    child: Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width /8,
                          height: MediaQuery.of(context).size.width /8 ,
                          margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                          // ignore: deprecated_member_use
                          child: RaisedButton(
                              color: _currentColor,
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (context){
                                      return AlertDialog(
                                        content: BlockPicker(
                                            pickerColor: _currentColor,
                                            onColorChanged: pickColor,
                                             availableColors: [Colors.deepOrangeAccent,Colors.deepPurpleAccent],
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: (){
                                                print(_pickedColor.toString());
                                                setState(() {
                                                  _currentColor=_pickedColor;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('확인')
                                          )
                                        ],
                                      );
                                    },
                                );
                              }
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/4 - 50,
                          height: MediaQuery.of(context).size.width /7,
                          margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                          child: TextField(
                            decoration: InputDecoration(
                                border:OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.black54,)),
                                labelText: '넓은 범위일수록 좋아요!',
                                labelStyle: TextStyle(color: Colors.black54)
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width /8,
                          height: MediaQuery.of(context).size.width /8 ,
                          margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                          child: TextButton(
                              child: Text('추가', style: TextStyle(color: Colors.black),),
                              style: ButtonStyle(
                              ),
                              onPressed: ()=>print("done")
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: tags.length,
                    itemBuilder: (context,index){
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                        height: 50,
                        color: tags[index].getTagColor(),
                        child: Center(
                          child: Text('${tags[index].getTagName()}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
        )
    );
  }
}

//floting button
class AddImgFAB extends StatefulWidget{
  @override
  _AddImgFABState createState() => _AddImgFABState();
}

class _AddImgFABState extends State<AddImgFAB> {
  //Camera (image_picker) Area
  File _image =null;
  final picker = ImagePicker();
  Future getImage(ImageSource imageSource) async{
    final pickedFile = await picker.getImage(source: imageSource);
    print('image_picker start');
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: _image!=null ? Image.file(_image): Icon(Icons.photo),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.check, color: Colors.black,)
                  )
                ]
            );
          },
        );
      } else {
        print('No image selected.');
      }
    });
    print('image_picker end');
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          setState(() {
            showDialog(
                context: context,
                builder: (context){
                  return AlertDialog(
                    content: Text('이미지를 불러주세요.'),
                    actions: [
                      IconButton(
                          icon: Icon(Icons.photo),
                          onPressed:(){
                          getImage(ImageSource.gallery);
                          Navigator.of(context).pop();
                        }
                      ),
                      IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed:(){
                            getImage(ImageSource.camera);
                            Navigator.of(context).pop();
                          }
                      ),
                    ],
                  );
                }
            );
          }); //setState
        },
    );
  }
}