import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:autocalen/models/User.dart' as userModel;

class UserData with ChangeNotifier{
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection("UserList");

  String _uid = '';
  String _name = '';
  String _email='';
  String _photoURL='';
  String _signInWith='';
  bool _needAlarms = true;

  UserData(){
    if(auth.currentUser!=null){
      // (로그인 상태인 경우) Firestore에 있는 사용자 정보로 초기화
      users.doc(auth.currentUser.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          userModel.User getUser = userModel.User.fromJson(documentSnapshot.data());
          _uid = auth.currentUser.uid;
          _name =getUser.name;
          _email =getUser.email;
          _photoURL = getUser.photoURL;
          _signInWith = getUser.signInWith;
          _needAlarms = getUser.needAlarms;
          print('${_signInWith} !userprovider needAlarms! ${_needAlarms}');
        }
      });
    }
  }

  getUid ()=> _uid;
  getName() => _name;
  getEmail() => _email;
  getPhotoURL() => _photoURL;
  getSignInWith() => _signInWith;
  getNeedAlarms() => _needAlarms;

  setUid(String uid)=> _uid =uid;
  setName(String name)=> _name= name;
  setEmail(String email)=> _email= email;
  setPhotoURL(String photoURL)=> _photoURL= photoURL;
  setSignInWith(String signInWith)=> _signInWith= signInWith;
  setNeedAlarms(bool needAlarms)=> _needAlarms = needAlarms;

  void setUserData(String signInWith){ // 로그인 시 사용자 정보 저장
    users.doc(auth.currentUser.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print("파이어스토어 documentSnapshot.exists TRUE");
        userModel.User getUser = userModel.User.fromJson(documentSnapshot.data());
        _uid = auth.currentUser.uid;
        _name =getUser.name;
        _email =getUser.email;
        _photoURL = getUser.photoURL;
        _signInWith = getUser.signInWith;
        _needAlarms = getUser.needAlarms;
        print('${_signInWith} !userprovider needAlarms! ${_needAlarms}');
      }
      else{
        print("파이어스토어 documentSnapshot.exist FALSE");
        _uid = auth.currentUser.uid;
        _name = auth.currentUser.displayName;
        _email= auth.currentUser.email;
        _photoURL = auth.currentUser.photoURL;
        _signInWith= signInWith;
        _needAlarms = true;
      }
    });

    notifyListeners(); // 값이 변할때마다 플러터 프레임워크에 알려줌
  }
  void userNotifiListeners(){
    notifyListeners();
    print('noti listeners');
  }

  void resetUserData(){ // 로그아웃 시 사용자 정보 초기화
    _uid = null;
    _name =null;
    _email =null;
    _photoURL = null;
    _signInWith = null;
    _needAlarms = null;
  }
}