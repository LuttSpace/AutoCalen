
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MainFAB extends StatefulWidget{
  @override
  _MainFABState createState() => _MainFABState();
}

class _MainFABState extends State<MainFAB> {
  //Camera (image_picker) Area
  File _image =null;
  final picker = ImagePicker();
  Future getImage(ImageSource imageSource) async{
    final pickedFile = await picker.getImage(source: imageSource);
    print('image_picker start');
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                content: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: _image!=null ? Image.file(_image): Icon(Icons.photo),
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: (){
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.check, color: Colors.black,)
                  )
                ]
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
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: (){
        setState(() {
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  content: Text('이미지를 불러주세요.'),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.photo),
                        onPressed:(){
                          getImage(ImageSource.gallery);
                          Navigator.of(context).pop();
                        }
                    ),
                    IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed:(){
                          getImage(ImageSource.camera);
                          Navigator.of(context).pop();
                        }
                    ),
                  ],
                );
              }
          );
        }); //setState
      },
    );
  }
}