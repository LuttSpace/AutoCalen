
import 'dart:io';

import 'package:autocalen/function/UploadImg.dart' as ImgUpload;
import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/widgets/ScheduleInputModal.dart' as ScheduleInputModal;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

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
  File _image =null;
  final picker = ImagePicker();

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
              height: 70,
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
                          ImgUpload.uploadFile(_image, userProvider, widget.isMain, widget.date).then((value) => print("백엔드 처리 완료!!!!!!!!!!!!!!!!"));
                          Navigator.of(context).pop();
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
