
import 'dart:io';

import 'package:autocalen/widgets/ScheduleInputModal.dart' as ScheduleInputModal;
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:autocalen/Function/UploadImg.dart' as ImgUpload;

class DayDialogFAB extends StatefulWidget {
  DateTime _date;
  DayDialogFAB(this._date);
  @override
  _DayDialogFABState createState() => _DayDialogFABState();
}

class _DayDialogFABState extends State<DayDialogFAB>
    with SingleTickerProviderStateMixin {
  //Camera (image_picker) Area
  File _image =null;
  final picker = ImagePicker();
  Future getImage(ImageSource imageSource) async{
    final pickedFile = await picker.getImage(source: imageSource);
    print('image_picker start');
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
                        ImgUpload.uploadFile(_image);
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
    print('image_picker end');
  }

  @override
  Widget build(BuildContext context) {
    return
      SpeedDial(
      child: Icon(Icons.add),
      activeIcon: Icons.clear,
      overlayOpacity: 0,
      children: [ //stack 구조임
        SpeedDialChild(
          child: Icon(Icons.edit),
          onTap: ()=>ScheduleInputModal.show(context,null, date: widget._date),
        ),
        SpeedDialChild(
          child:Icon(Icons.camera_alt),
          onTap: ()=>getImage(ImageSource.camera),
        ),
        SpeedDialChild(
          child:Icon(Icons.photo),
          onTap: ()=>getImage(ImageSource.gallery),
        )
      ],
    );
  }
}
