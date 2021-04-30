import 'package:autocalen/models/UserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autocalen/models/User.dart' as userModel;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

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

  // 카카오 로그인 버튼 클릭시 호출
  // https://developers.kakao.com/docs/latest/ko/kakaologin/rest-api
  Future<UserCredential> signInWithKakao() async {
    final clientState = Uuid().v4();
    // 인가 코드 받기
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize',{
      'response_type':'code', // 'code'로 고정
      'client_id':"995c38bd950403d0f8991768d4eb6d11", // 앱 생성 시 발급받은 REST API 키
      'response_mode': 'form_post',
      'redirect_uri':'https://metal-ancient-panama.glitch.me/callbacks/kakao/sign_in', // 인가 코드가 리다이렉트될 URI
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token',{
      'grant_type':'authorization_code', // authorization_code로 고정
      'client_id':"995c38bd950403d0f8991768d4eb6d11",
      'redirect_uri':'https://metal-ancient-panama.glitch.me/callbacks/kakao/sign_in',
      'code': body['code'], // 인가 코드 받기 요청으로 얻은 인가 코드 (토큰 받기 요청에 필요)
    });
    var response = await http.post(tokenUrl);
    print('Response status: ${response.statusCode}');
    var accessTokenResult = json.decode(response.body);
    print(accessTokenResult);
    print(accessTokenResult['access_token']); // 사용자 액세스 토큰 값

    var responseCustomToken = await http.post(
        Uri.parse("https://metal-ancient-panama.glitch.me/callbacks/kakao/token"),
        body: {"accessToken": accessTokenResult['access_token']});

    // Firebase Authentication 에 사용자 등록
    return await FirebaseAuth.instance.signInWithCustomToken(responseCustomToken.body);
  }

  // 네이버 로그인 버튼 클릭시 호출
  // https://developers.naver.com/docs/login/web/web.md
  Future<UserCredential> signInWithNaver() async {
    final clientState = Uuid().v4();
    // 인가 코드 받기
    final url = Uri.https('nid.naver.com', '/oauth2.0/authorize',{
      'response_type':'code', // 'code'로 고정
      'client_id':"jUzqcfuX58OZwvo6AU06", // 앱 생성 시 발급받은 REST API 키
      'response_mode': 'form_post',
      'redirect_uri':'https://metal-ancient-panama.glitch.me/callbacks/naver/sign_in', // 인가 코드가 리다이렉트될 URI
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(), callbackUrlScheme: "webauthcallback");

    final body = Uri.parse(result).queryParameters;
    print(body);

    final tokenUrl = Uri.https('nid.naver.com', '/oauth2.0/token',{
      'grant_type':'authorization_code', // authorization_code로 고정
      'client_id':"jUzqcfuX58OZwvo6AU06",
      'client_secret':'8yFXh9NaNK',
      'code': body['code'], // 인가 코드 받기 요청으로 얻은 인가 코드 (토큰 받기 요청에 필요)
      'state': clientState
    });
    var response = await http.post(tokenUrl);
    var accessTokenResult = json.decode(response.body);
    print(accessTokenResult);
    print(accessTokenResult['access_token']); // 사용자 액세스 토큰 값

    var responseCustomToken = await http.post(
        Uri.parse("https://metal-ancient-panama.glitch.me/callbacks/naver/token"),
        body: {"accessToken": accessTokenResult['access_token']});

    // Firebase Authentication 에 사용자 등록
    return await FirebaseAuth.instance.signInWithCustomToken(responseCustomToken.body);
  }

  //===============================================================


  @override
  Widget build(BuildContext context) {
    double btnWidth = MediaQuery.of(context).size.width*0.6;
    double btnHeight = MediaQuery.of(context).size.height*0.08;
    final userProvider = Provider.of<UserData>(context, listen: false);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              child: Image.asset('images/logo/logo_only.png', width: 250.0, height: 250),
            ),
            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () => signInWithGoogle().then((value) {
                addNewUser(context, value.user, 'google');
                userProvider.setUserData('google');
              }), // 구글 로그인 후 사용자 정보 저장
              child: SizedBox(
                  width: 300,
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'images/icon/google_icon.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Text("구글 로그인",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              style: ElevatedButton.styleFrom(
                // background color
                //minimumSize: Size(300,50),
                primary: Colors.white,
                //padding: EdgeInsets.fromLTRB(20, 10, 50, 10),
                textStyle: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () =>signInWithKakao().then((value) {
                addNewUser(context, value.user, 'kakao');
                userProvider.setUserData('kakao');
              }), //
              child: SizedBox(
                  width: 300,
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.all(
                                Radius.circular(5.0) //
                            ),
                          ),
                          child: Icon(Icons.chat_bubble,
                          color: Color(0xFF000000),
                          size: 20,
                        ),
                      )),
                      Expanded(
                        flex: 8,
                        child: Text("카카오 로그인",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              style: ElevatedButton.styleFrom(
                // background color
                primary: Colors.white, //Color(0xFFFEE500),
                //padding: EdgeInsets.fromLTRB(20, 10, 50, 10),
                textStyle: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
            SizedBox(height: 15.0),
            ElevatedButton(
              onPressed: () => signInWithNaver().then((value) {
                addNewUser(context, value.user, 'naver');
                userProvider.setUserData('naver');
              }),
              child: SizedBox(
                  width: 300,
                  height: 60,
                  child: Row(
                    children: [
                      Expanded(
                        child: Image.asset(
                          'images/icon/naver_icon.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Text("네이버 로그인",textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              style: ElevatedButton.styleFrom(
                // background color
                primary: Colors.white, //Color(0xFF1EC800),
                textStyle: TextStyle(fontSize: 20, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Firestore에 사용자 정보 저장
  void addNewUser(BuildContext context, User currentUser, String signInWith){
    CollectionReference users = _firebaseFirestore.collection("UserList");
    users.doc(currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (!documentSnapshot.exists) { // Firestore에 사용자 정보 없을 경우 추가
        userModel.User user = userModel.User(currentUser.displayName, currentUser.email, currentUser.photoURL, signInWith);
        users.doc(currentUser.uid).set(user.toJson());
      }
      else{ // Firestore에 사용자 정보 있는 경우 출력
        userModel.User getUser = userModel.User.fromJson(documentSnapshot.data());
        print(getUser.name+", "+ getUser.email+", "+ getUser.photoURL+", "+ getUser.signInWith);
      }
    });
  }
}
