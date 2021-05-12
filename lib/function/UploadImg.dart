
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


Future<dynamic> uploadFile(File imgFile, dynamic userProvider, bool isMain, DateTime dateTime) async {
  String uploadName = userProvider.getUid()+'_img';
  var response;
  try {
    await firebase_storage.FirebaseStorage.instance
        .ref(uploadName)
        .putFile(imgFile).then((snapshot) {
          print('업로드 성공');
          print(uploadName);
          downloadURLExample(uploadName, userProvider.getUid(), isMain, dateTime).then((value) {
            response = value;
            return response;
          });
          print('url 성공');
        });
  } on firebase_core.FirebaseException catch (e) {
    // e.g, e.code == 'canceled'
    print(e.code);
  }

}

Future<dynamic> downloadURLExample(String uploadName, String userId, bool isMain, DateTime dateTime) async {
  try{
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(uploadName)
        .getDownloadURL();

    print('downloadURL ${downloadURL}');
    return callBackend(downloadURL, userId, isMain, dateTime);
  } on firebase_core.FirebaseException catch(e){
    print('error');
    print(e.code);
    print('error end');
  }

  // Within your widgets:
  // Image.network(downloadURL);
}

Future<dynamic> callBackend(String downloadURL, String id, bool isMain, DateTime dateTime) async{
  // String frontURL = 'https://test01-ddxigpyw2q-de.a.run.app/?url=';
  String frontURL = 'https://autocalen1-sw4ivbhnwa-de.a.run.app/?_url=';
  String userId = '&_id=${id}';
  String date;

  // isMain: true > 메모지에 작성한거 호출
  if(isMain){
    date ='';
  }
  // isMain: false > calender에서 찍은 사진 호출
  else{
    date ='&year=${dateTime.year}&month=${dateTime.month}&day=${dateTime.day}';
  }

  print('full url ${frontURL+downloadURL+userId+date}');
  var response = await http.get(Uri.parse(frontURL+downloadURL+userId+date));
  var statusCode = response.statusCode;
  var responseHeaders = response.headers;
  var responseBody = response.body;

  print("statusCode: ${statusCode}");
  print("responseHeaders: ${responseHeaders}");
  print("responseBody: ${responseBody}");
  return responseBody;
}