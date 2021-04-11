import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
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
              onPressed: () => signInWithGoogle(),
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
              onPressed: () =>signInWithKakao(),
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
              onPressed: () => signInWithNaver(),
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
