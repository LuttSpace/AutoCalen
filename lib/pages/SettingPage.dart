import 'package:flutter/material.dart';

class Setting extends StatefulWidget{
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
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

          ],
        ),
      ),
    );

  }
}