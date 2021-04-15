
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

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
    print('result Url: '+downloadURL);
  } on firebase_core.FirebaseException catch(e){
    print(e.code);
  }

  // Within your widgets:
  // Image.network(downloadURL);
}