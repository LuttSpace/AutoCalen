import 'package:autocalen/models/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget{
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  Future _cancelNoti() async {
    print('cancel start');
    var androidInit = new AndroidInitializationSettings('logo_no'); //should change into our logo
    var IOSInit = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: androidInit,iOS: IOSInit);
    FlutterLocalNotificationsPlugin localNotifications=FlutterLocalNotificationsPlugin();
    localNotifications.initialize(initSettings);
    await localNotifications.cancelAll().then((value) => print('cancel succeed'));
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserData>(context, listen: false);
    // needAlams setting
    bool needAlarms = userProvider.getNeedAlarms();
    print(needAlarms);
    return MaterialApp(
      theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: Colors.black
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('설정'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: ()=> Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 35,horizontal: 30),
              //padding: EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('일정 알람', style: TextStyle(fontSize: 20.0)),
                  FlutterSwitch(
                      width: 60.0,
                      height: 25.0,
                      value: needAlarms,
                      activeColor: Colors.black,
                      onToggle: (val){
                        setState((){
                          needAlarms = val;
                          FirebaseFirestore.instance.collection("UserList")
                            .doc(userProvider.getUid())
                            .update({'needAlarms':needAlarms})
                            .then((value) => print('needAlarms changed ${needAlarms}'));
                          userProvider.setNeedAlarms(needAlarms);
                        });
                          if(!needAlarms) _cancelNoti();
                      }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}