import 'package:autocalen/models/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget{
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  //size
  double _width;
  double _heigth;
  //alarm
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

  //user info
  var userProvider;

  //logout
  FirebaseAuth auth = FirebaseAuth.instance;
  signOut() async {
    await auth.signOut();
  }


  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserData>(context, listen: false);
    needAlarms=userProvider.getNeedAlarms();
  }

  @override
  Widget build(BuildContext context) {
    // needAlams setting
    _width = MediaQuery.of(context).size.width;
    _heigth = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          // actions: [
          //   IconButton(
          //     icon:Icon(Icons.check),
          //     onPressed: (){
          //       FirebaseFirestore.instance.collection("UserList")
          //           .doc(userProvider.getUid())
          //           .update({'needAlarms':needAlarms})
          //           .then((value) => print('needAlarms changed ${needAlarms}'));
          //       userProvider.setNeedAlarms(needAlarms);
          //       userProvider.userNotifiListeners();
          //       if(!needAlarms) _cancelNoti();
          //       Navigator.of(context).pop();
          //       Navigator.of(context).pop();
          //     },
          //   )
          // ],
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: _width/25,horizontal: _width/25),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.notifications,color: Colors.black,),
                title: Text('일정 알림',style: TextStyle(color:Colors.black,fontSize: _width/22),),
                trailing: Container(
                  width: 60,
                  child: FlutterSwitch(
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
                          userProvider.userNotifiListeners();
                          if(!needAlarms) _cancelNoti();
                        });
                      }
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.black,),
                title: Text('로그아웃',style: TextStyle(color:Colors.black,fontSize: _width/22)),
                onTap: (){
                  print('로그아웃');
                  Navigator.pop(context);
                  signOut();
                  userProvider.resetUserData(); // Provider 사용자 정보 초기화
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}