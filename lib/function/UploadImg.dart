
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:http/http.dart' as http;

String uploadName = 'file-to-upload.png';

Future<void> uploadFile(File imgFile) async {

  try {
    await firebase_storage.FirebaseStorage.instance
        .ref(uploadName)
        .putFile(imgFile).then((snapshot) {
          print('업로드 성공');
          downloadURLExample();
          print('url 성공');
        });
  } on firebase_core.FirebaseException catch (e) {
    // e.g, e.code == 'canceled'
    print(e.code);
  }

}

Future<void> downloadURLExample() async {
  try{
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(uploadName)
        .getDownloadURL();

    print('downloadURL ${downloadURL}');
    callBackend(downloadURL);
  } on firebase_core.FirebaseException catch(e){
    print('error');
    print(e.code);
    print('error end');
  }

  // Within your widgets:
  // Image.network(downloadURL);
}

Future<void> callBackend(String downloadURL) async{
  String frontURL = 'https://test01-ddxigpyw2q-de.a.run.app/?url=';

  print('full url ${frontURL+downloadURL}');
  var response = await http.get(Uri.parse(frontURL+downloadURL));
  var statusCode = response.statusCode;
  var responseHeaders = response.headers;
  var responseBody = response.body;

  print("statusCode: ${statusCode}");
  print("responseHeaders: ${responseHeaders}");
  print("responseBody: ${responseBody}");
}