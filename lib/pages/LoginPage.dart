import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  // 구글 로그인 버튼 클릭시 호출
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    double btnWidth = MediaQuery.of(context).size.width*0.6;
    double btnHeight = MediaQuery.of(context).size.height*0.08;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // TextButton.icon(
            //   icon: Icon(Icons.chat_bubble,
            //     color: Colors.black,
            //   ),
            //   label: Text('Google 로그인',
            //     style: TextStyle(
            //       color: Colors.white
            //     ),
            //   ),
            //   style: TextButton.styleFrom(
            //     //primary: Colors.grey,
            //     backgroundColor: Colors.grey
            //   ),
            //   onPressed: signInWithGoogle,
            // ),
            // TextButton.icon(
            //   icon: Icon(Icons.chat_bubble),
            //   label: Text('카카오 로그인',
            //       style: TextStyle(
            //       color: Colors.brown
            //   ),),
            //   style: TextButton.styleFrom(
            //     backgroundColor: Colors.yellow
            //   ),
            //   //onPressed: signInWithGoogle,
            // ),
            // // TextButton.icon(
            // //   icon: Icon(Icons.chat_bubble,
            // //     color: Color(0xFFFFFFFF)
            // //   ),
            // //   label: Text('네이버 로그인',
            // //     style: TextStyle(
            // //         color: Colors.white
            // //     ),
            // //   ),
            // //   style: TextButton.styleFrom(
            // //     //primary: Colors.green,
            // //     backgroundColor: Color(0xFF1EC800)
            // //   ),
            // //   //onPressed: signInWithGoogle,
            // // ),
            Hero(
              tag: 'hero',
              child: CircleAvatar(
                child: Icon(Icons.calendar_today, size: 50.0,),
                backgroundColor: Colors.transparent,
                radius: 58.0,
              ),
            ),
            SizedBox(height: 45.0),
            ElevatedButton.icon(
              onPressed: () {
                // Respond to button press
                signInWithGoogle();
              },
              icon: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Image.asset(
                  'images/icon/google_icon.png',
                  width: 25,
                  height: 25,
                ),
              ),
              label: Text("구글 로그인",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // background color
                primary: Colors.white70,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                // Respond to button press
              },
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.chat_bubble,
                  color: Color(0xFF000000),
                  size: 25,
                ),
              ),
              label: Text("카카오 로그인",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // background color
                primary: Color(0xFFFEE500),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                // Respond to button press
              },
              icon: Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Image.asset(
                  'images/icon/naver_icon.png',
                  width: 30,
                  height: 30,
                ),
              ),//Icon(Icons.add, size: 18),
              label: Text("네이버 로그인",),
              style: ElevatedButton.styleFrom(
                // background color
                primary: Color(0xFF1EC800),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
