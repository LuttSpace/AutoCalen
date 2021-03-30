import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(MainPage());
}

class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _monthName ='';
  String _yearName='';
  void viewChanged(ViewChangedDetails viewChangedDetails){
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
        home: Scaffold(
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
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add_a_photo),
            foregroundColor: Colors.white,
          ),
        ),
    );
  }
}