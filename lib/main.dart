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
          leading: IconButton(
            icon: Icon(Icons.menu),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: (){
                  print('today');
                })
          ],
          shadowColor: Colors.transparent,
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

class AddImgFAB extends StatefulWidget{
  @override
  _AddImgFABState createState() => _AddImgFABState();
}

class _AddImgFABState extends State<AddImgFAB> {
  //Camera (image_picker) Area
  File _image;
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
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: _image!=null ? Icon(Icons.photo): Image.file(_image),
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
  //FAB Controll Area
  Icon _addIcon = Icon(Icons.add);
  Color _addBColor = Colors.black;
  Color _addFColor = Colors.white;
  bool _isVisible = false;

  void showFloatingBtns(){
    setState(() {
      _isVisible = !_isVisible;
      if(_isVisible) {
        _addIcon = Icon(Icons.clear);
        _addBColor = Color(0xfff1f3f5);
        _addFColor = Colors.black;
      }
      else {
        _addIcon = Icon(Icons.add);
        _addBColor = Colors.black;
        _addFColor = Colors.white;
      }
    });

    print(_isVisible);
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: _isVisible,
          child: Container(
            padding: EdgeInsets.only(bottom:120),
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              heroTag: "Personal",
              onPressed: ()=>getImage(ImageSource.gallery),
              child: Icon(Icons.photo_library),
            ),
          ),
        ),
        Visibility(
          visible: _isVisible,
          child: Container(
            padding: EdgeInsets.only(bottom:60),
            alignment:Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              heroTag: "Camera",
              onPressed:()=> getImage(ImageSource.camera),
              child: Icon(Icons.camera_alt),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            heroTag: "AddSchedule",
            backgroundColor: _addBColor,
            foregroundColor: _addFColor,
            onPressed: ()=> showFloatingBtns(),
            child: _addIcon,
          ),
        ),
      ],
    );
  }
}