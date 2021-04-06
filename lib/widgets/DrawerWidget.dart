import 'package:autocalen/pages/TagSettingPage.dart';
import 'package:flutter/material.dart';

class ShowDrawer extends StatefulWidget{
  @override
  _ShowDrawerState createState() => _ShowDrawerState();
}

class _ShowDrawerState extends State<ShowDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                //Navigator.push(context, MaterialPageRoute(builder: (context)=> TagSetting()));
                Navigator.pushNamed(context, '/tagSetting');
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
    );
  }
}
