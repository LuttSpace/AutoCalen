import 'package:autocalen/models/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Setting extends StatefulWidget{
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  //size
  double _width;
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

  //info of ottocalen
  String explain = '''일정 정리 오또칼렌?
바쁜 현대인들을 위한 일정 정리 자동화 솔루션!

기존 캘린더 앱은 직접 일정 태그 등록을 해주지 않으면 어떤 일정인지 한눈에 알아보기 쉽지 않아 관리가 어렵습니다. 그리고 아날로그 감성도 포기하지 않는 현대인에게 기존 다이어리를 일일이 디지털화하는 것은 여간 귀찮은 일이 아닙니다.

오또 칼렌은 종이로 된 아날로그 다이어리를 사진 촬영하면 일정에 맞게 태그가 되어 디지털 캘린더에 연동합니다. 그러므로 흩어져 있는 일정들을 태그별로 분류하여 한눈에 알아보기 쉽고, 일정 관리가 수월해집니다.

작품명 오또칼렌은 "Automatic"과 "Calendar"를 합친 것을 한글로 발음하여 표기했습니다.''';
  //launch url
  String _videoUrl = 'https://youtu.be/4prgEn_bIYg';
  String _githubUrl = 'https://github.com/LuttSpace';
  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url, forceWebView: true, forceSafariVC: true,enableJavaScript: true) : throw 'Could not launch $url';
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
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.black,),
                title: Text('오또칼렌?!',style: TextStyle(color:Colors.black,fontSize: _width/22)),
                onTap: (){
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.8,
                            child: SingleChildScrollView(
                              child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: _width/20),
                                  child: Column(
                                    children: [
                                      Image.asset('drawable/logo/logo.png'),
                                      Text('오또칼렌 ottocalen', textAlign: TextAlign.center, style: TextStyle(fontSize: _width/22,fontFamily: 'Schyler',)),
                                      SizedBox(height: 20,),
                                      Text(explain,style: TextStyle(fontSize: _width/23)), //style: TextStyle(fontSize: _width/30,fontFamily: 'Schyler',)
                                      SizedBox(height: 20,),
                                      ElevatedButton(
                                        child: Center(child: Text('소개 영상')),
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff62C2A3)),
                                        ),
                                        onPressed: (){ _launchURL(_videoUrl); },
                                      ),
                                      SizedBox(height: 5,),
                                      ElevatedButton(
                                          child: Center(child: Text('GitHub',)),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xff62C2A3)),
                                          ),
                                          onPressed: (){ _launchURL(_githubUrl); },
                                      ),
                                      SizedBox(height: 20,),
                                    ],
                                  )
                              ),
                            )
                          )
                        );
                      },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}