import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/pages/TagSettingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserData>(context, listen: false);
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

    return Drawer(
        child: userProvider.getUid() != null? ListView(
          children: [
            UserAccountsDrawerHeader(
              arrowColor: Colors.pink,
              accountEmail: Text('${userProvider.getEmail()}'),
              accountName: Text('${userProvider.getName()}'),
              currentAccountPicture: CircleAvatar(
                child: userProvider.getPhotoURL()==null ? Icon(Icons.person,color: Colors.black): null,
                backgroundImage: userProvider.getPhotoURL()!=null? NetworkImage(userProvider.getPhotoURL()):null,
                backgroundColor: Colors.white,
              ),
              decoration: BoxDecoration(
                  color: Colors.black12
              ),
            ),
            Theme(
              data: theme,
              child: ExpansionTile(
                  leading: Icon(Icons.tag),
                  title: Text('태그'),
                  children: [
                    ListTile(
                      leading: Icon(Icons.color_lens, color: Colors.transparent,),
                      title: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('한 눈에 보기'),
                          ),
                        ],
                      ),
                      onTap: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context)=> TagSetting()));
                        Navigator.pushNamed(context, '/sortedListByTag');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.color_lens, color: Colors.transparent,),
                      title: Row(
                        children: [
                          Icon(Icons.color_lens),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('설정'),
                          ),
                        ],
                      ),
                      onTap: () {
                        print('설정');
                        //Navigator.push(context, MaterialPageRoute(builder: (context)=> TagSetting()));
                        Navigator.pushNamed(context, '/tagSetting');
                      },
                    ),
                  ]
              ),
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
                userProvider.resetUserData(); // Provider 사용자 정보 초기화
              },
            ),
          ],
        ): null,
    );
  }
}
