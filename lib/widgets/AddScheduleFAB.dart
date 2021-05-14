
import 'dart:io';

//import 'package:autocalen/function/UploadImg.dart' as ImgUpload;
import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/widgets/ScheduleInputModal.dart' as ScheduleInputModal;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:http/http.dart' as http;

class AddScheduleFAB extends StatefulWidget {
  bool isMain;
  DateTime date;
  AddScheduleFAB(this.isMain,{this.date});
  @override
  _AddScheduleFABState createState() => _AddScheduleFABState();
}

class _AddScheduleFABState extends State<AddScheduleFAB>
    with SingleTickerProviderStateMixin {
  //Camera (image_picker) Area
  File _image = null;
  final picker = ImagePicker();

  // response 상태 확인 (로딩화면)
  var responseState= 0; // 기본
  var responseCode=0;

  // ocr 기능
  // Future<dynamic> uploadingManager(File imgFile,dynamic userProvider,bool isMain,DateTime)async{
  //
  // }
  Future<dynamic> uploadFile(File imgFile, dynamic userProvider, bool isMain, DateTime dateTime) async {
    String uploadName = userProvider.getUid()+'_'+DateTime.now().millisecondsSinceEpoch.toString();
    var response;
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(uploadName)
          .putFile(imgFile).then((snapshot) {
        print('업로드 성공');
        print(uploadName);
        downloadURLExample(uploadName, userProvider.getUid(), isMain, dateTime).then((value) {
          response = value;
          responseState = 2; // 처리 완료
          Navigator.pop(context); // '로딩 중' 다이얼로그 pop
          _showLoadingStatusDialog(); // '처리 완료' 다이얼로그
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
    print('downloadURLExample 함수 호출');
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
  }

  Future<dynamic> callBackend(String downloadURL, String id, bool isMain, DateTime dateTime) async{
    print('callBackend 함수 호출');
    //String frontURL = 'https://autocalen1-sw4ivbhnwa-de.a.run.app/?_url=';
    String frontURL = 'https://autocalen2-sw4ivbhnwa-de.a.run.app/?_url=';
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

    responseCode = statusCode;
    print("statusCode: ${statusCode}");
    print("responseHeaders: ${responseHeaders}");
    print("responseBody: ${responseBody}");
    return responseBody;
  }
  //이미지 불러오기
  Future getImage(ImageSource imageSource) async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 2), () async { Navigator.pop(context);});
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          content: SizedBox(
              height: MediaQuery.of(context).size.height*0.13, // 70
              child: Center(child: Text('✍️\n일정 (날짜) / 내용 / 시간 으로 적어주세요!\n날짜는 필수는 아니랍니다',textAlign: TextAlign.center,))
          ),
        );
      },
    ).then((value) async {
      final pickedFile = await picker.getImage(source: imageSource);
      print('image_picker start ${pickedFile.toString()}');
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
          showBarModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      height: MediaQuery.of(context).size.height/15,
                      child: TextButton(
                        child: Text("확인",style: TextStyle(color: Colors.black),),
                        onPressed: (){
                          var userProvider = Provider.of<UserData>(context, listen: false);

                          uploadFile(_image, userProvider, widget.isMain, widget.date).then((value) async {
                            print("백엔드 처리 완료!!!!!!!!!!!!!!!! $value");
                          });
                          Navigator.of(context).pop();
                          responseState =1; // 로딩중
                          // 로딩화면 띄우기
                          _showLoadingStatusDialog();
                        },
                      ),
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height/10*8,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child : _image!=null ? Image.file(_image): Icon(Icons.photo),
                        )
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          print('No image selected.');
        }
      });
    });
  }

  _showLoadingStatusDialog() {
    Widget content;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (BuildContext context, Animation animation, Animation secondAnimation){
        if(responseState==1){ // 로딩중
          content = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                Image.asset(
                  "drawable/logo/loading.gif",
                  width: MediaQuery.of(context).size.width,//200.0,
                ),
                Text("등록 중",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
              ]
          );
        }
        else if(responseState==2){ //처리 완료
          Future.delayed(Duration(seconds: 4), () async { Navigator.pop(context);});

          if(responseCode!=0){
            if(responseCode==200) content= Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text('😊',style:TextStyle(fontSize: 50)),
                  // Image.asset(
                  //   "drawable/logo/logo.png",
                  //   width: MediaQuery.of(context).size.width,//200.0,
                  // ),
                  SizedBox(width: 100, height: 15,),
                  Text("등록 완료",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ]
            );
            else content = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text('😥',style:TextStyle(fontSize: 50)),
                  // Image.asset(
                  //   "drawable/logo/logo.png",
                  //   width: MediaQuery.of(context).size.width,//200.0,
                  // ),
                  SizedBox(width: 100, height: 15,),
                  Text("등록 실패\n다시 시도해주세요.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ]
            );
          }
          responseState =0; // 처리 완료 후 다시 초기 상태로
        }
        return Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: content,
              ),
            ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      SpeedDial(
      child: Icon(Icons.add),
      backgroundColor: Color(0xFF323232),
      foregroundColor: Color(0xffefefef),
      activeIcon: Icons.clear,
      overlayOpacity: 0,
      children: [ //stack 구조임
        SpeedDialChild(
          child: Icon(Icons.edit),
          backgroundColor: Color(0xFF323232),
          foregroundColor: Color(0xffefefef),
          onTap: (){
            if(!widget.isMain) ScheduleInputModal.show(false,widget.isMain,context,null, date:widget.date);
            else ScheduleInputModal.show(false,widget.isMain,context, null, date:DateTime.now());
          },
        ),
        SpeedDialChild(
          child:Icon(Icons.camera_alt),
          backgroundColor: Color(0xFF323232),
          foregroundColor: Color(0xffefefef),
          onTap: ()=>getImage(ImageSource.camera),
        ),
        SpeedDialChild(
          child:Icon(Icons.photo),
          backgroundColor: Color(0xFF323232),
          foregroundColor: Color(0xffefefef),
          onTap: ()=>getImage(ImageSource.gallery),
        )
      ],
    );
  }
}
