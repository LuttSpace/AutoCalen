import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
                  print('today');
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
          ),
        ),
        floatingActionButton: AddImgFAB()
    );
  }
}

//파일 분리 하고 싶음

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