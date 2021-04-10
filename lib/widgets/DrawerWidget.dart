import 'package:autocalen/pages/TagSettingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShowDrawer extends StatefulWidget{
  @override
  _ShowDrawerState createState() => _ShowDrawerState();
}

class _ShowDrawerState extends State<ShowDrawer> {
  FirebaseAuth auth = FirebaseAuth.instance;

  signOut() async {
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser != null) {
      return Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                arrowColor: Colors.pink,
                accountEmail: Text('${auth.currentUser.email}'),
                accountName: Text('${auth.currentUser.displayName}'),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(auth.currentUser.photoURL),
                ),
                decoration: BoxDecoration(
                    color: Colors.black12
                ),
              ),
              ListTile(
                leading: Icon(Icons.color_lens),
                title: Text('태그 설정'),
                onTap: () {
                  print('태그 설정');
                  //Navigator.push(context, MaterialPageRoute(builder: (context)=> TagSetting()));
                  Navigator.pushNamed(context, '/tagSetting');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('설정'),
                onTap: () {
                  print('설정');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('로그아웃'),
                onTap: (){
                  print('로그아웃');
                  Navigator.pop(context);
                  signOut();
                },
              ),
            ],
          )
      );
    }
    return Drawer();
  }
}
