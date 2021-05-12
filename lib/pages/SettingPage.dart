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

  bool needAlarms;
  var userProvider;

  @override
  void initState() {
    userProvider = Provider.of<UserData>(context, listen: false);
    needAlarms=userProvider.getNeedAlarms();
  }

  @override
  Widget build(BuildContext context) {
    // needAlams setting
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
          actions: [
            IconButton(
              icon:Icon(Icons.check),
              onPressed: (){
                FirebaseFirestore.instance.collection("UserList")
                    .doc(userProvider.getUid())
                    .update({'needAlarms':needAlarms})
                    .then((value) => print('needAlarms changed ${needAlarms}'));
                userProvider.setNeedAlarms(needAlarms);
                userProvider.userNotifiListeners();
                if(!needAlarms) _cancelNoti();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            )
          ],
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
                        });
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