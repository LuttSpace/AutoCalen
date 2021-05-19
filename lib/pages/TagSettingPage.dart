
import 'dart:ui';

import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

List<Color> colorSet = [];
class TagTile extends StatefulWidget{
  TagTile(this._tag,this.userProvider);
  final userProvider;
  final Tag _tag;

  @override
  _TagTileState createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  bool _isChangeMode=false;
  Color _currentColor;
  var changeController;

  void updateTag(Tag currentTag){
    //태그 정보 업데이트
    CollectionReference tagHub = FirebaseFirestore.instance.collection("UserList").doc(widget.userProvider.getUid()).collection('TagHub');

    tagHub.doc(currentTag.tid)
          .update(currentTag.toJson())
          .then((value){
        print('sucess updating');
      });
    // 일정 마다 태그 업데이트.
    CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(widget.userProvider.getUid()).collection('ScheduleHub');

    scheduleHub.where('tag.tid',isEqualTo: currentTag.tid).get().then((response){
        response.docs.forEach((doc){
            var docRef = scheduleHub.doc(doc.id);
            docRef.update({'tag':currentTag.toJson()}).then((value) {print('tag update');});
        });
    });

  }
  void deleteTag(Tag currentTag){
    CollectionReference tagHub = FirebaseFirestore.instance.collection("UserList").doc(widget.userProvider.getUid()).collection('TagHub');
    tagHub.doc(currentTag.tid).delete().then((value) => print('succes deleting'));
    //태그 일정들 기타로 옮기기
    CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(widget.userProvider.getUid()).collection('ScheduleHub');

    scheduleHub.where('tag.tid',isEqualTo: currentTag.tid).get().then((response){
      response.docs.forEach((doc){
        print('doc id ${doc.id}');
        var docRef = scheduleHub.doc(doc.id);
        docRef.update({'tag.tid':'','tag.name':'기타'}).then((value) {print('tag delete');});
      });
    });
  }

  @override
  void initState() {
    _currentColor =widget._tag.getTagColor();
    changeController = TextEditingController(text: widget._tag.getTagName());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
        height: MediaQuery.of(context).size.width /8,
        child: ListTile(
          leading : Container(
            // width: MediaQuery.of(context).size.width /8,
            // height: MediaQuery.of(context).size.width /8,
            child: ElevatedButton(
              onPressed: (){
                if(_isChangeMode){
                  Color _pickedColor;
                  showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        content: Container(
                          width: 320,height: 500,
                          child: ColorPicker(
                            color: _currentColor,
                            onColorChanged: (color){
                              setState(() {
                                _pickedColor=color;
                              });
                            },
                            width: MediaQuery.of(context).size.width/7.5,
                            height: MediaQuery.of(context).size.width/13,
                            borderRadius: 4,
                            spacing: 5,
                            runSpacing: 5,
                            wheelDiameter: 155,
                            heading: Text(
                              '색을 선택해주세요',
                              style: TextStyle(fontSize: 15)
                            ),
                            subheading: Text(
                              '\n명도',
                                style: TextStyle(fontSize: 15)
                            ),
                            wheelSubheading: Text(
                              '\n명도',
                                style: TextStyle(fontSize: 15)
                            ),
                            showMaterialName: false,
                            showColorName: false,
                            showColorCode: true,
                            materialNameTextStyle: Theme.of(context).textTheme.caption,
                            colorNameTextStyle: Theme.of(context).textTheme.caption,
                            colorCodeTextStyle: Theme.of(context).textTheme.caption,
                            pickersEnabled: const <ColorPickerType, bool>{
                              ColorPickerType.both: false,
                              ColorPickerType.primary: true,
                              ColorPickerType.accent: true,
                              ColorPickerType.bw: false,
                              ColorPickerType.custom: true,
                              ColorPickerType.wheel: true,
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                              onPressed: (){
                                print('tag 수정');
                                if(_pickedColor==null){
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        content: SizedBox(
                                            height: 50,
                                            child: Center(child: Text('색 선택을 해주세요!'))
                                        ),
                                      );
                                    },
                                  );
                                }
                                else{
                                  print(_pickedColor.toString());
                                  setState(() {
                                    _currentColor=_pickedColor;
                                  });
                                  print(widget._tag.getTagColor());
                                  print(_currentColor);
                                  Navigator.of(context).pop();
                                }

                              },
                              child: Text('확인')
                          )
                        ],
                      );
                    },
                  );
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(!_isChangeMode? widget._tag.getTagColor():_currentColor),
              ),
            ),
          ),
          title: !_isChangeMode?
          Text(widget._tag.getTagName()) :
          Container(
            height: MediaQuery.of(context).size.width /7,
            child: TextField(
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.black54,)),
                labelText: '넓은 범위일수록 좋아요!',
                labelStyle: TextStyle(color: Colors.black54),
              ),
              controller: changeController,

            ),
          ),
          trailing: Container(
            //이거 안먹힌다.
            width: MediaQuery.of(context).size.width /4,
            height: MediaQuery.of(context).size.width /8,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width /8,
                  height: MediaQuery.of(context).size.width /8,
                  padding: EdgeInsets.all(0),
                  child: TextButton(
                    child: !_isChangeMode ? Text('삭제', style: TextStyle(color:Colors.red)) : Text('취소'),
                    onPressed: (){
                      if(!_isChangeMode){
                        deleteTag(widget._tag);
                        print('삭제');
                      }
                      else{
                        setState(() {
                          //원상복귀
                          _currentColor = widget._tag.getTagColor();
                          changeController.text = widget._tag.getTagName();
                          _isChangeMode = !_isChangeMode;
                        });
                        print('변경 사항 없음');
                      }
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width /8,
                  height: MediaQuery.of(context).size.width /8,
                  padding: EdgeInsets.all(0),
                  child: TextButton(
                    child: !_isChangeMode ? Text('변경', style: TextStyle(color:Colors.green)) : Text('확인'),
                    onPressed: (){
                      if(!_isChangeMode){ //변경 모드로 바꿈!
                        print("변경 모드!! ${widget._tag.tid}");
                        setState(() {
                          _currentColor =widget._tag.getTagColor();
                          changeController = TextEditingController(text: widget._tag.getTagName());
                          _isChangeMode = !_isChangeMode;
                          print(_isChangeMode);
                        });
                      }
                      else{ //변경하기 > 변경모드 해제
                        print('확인');
                        setState(() {
                          // widget._tag.setTagColor(_currentColor);
                          // if(changeController.text !='') {
                          //   widget._tag.setTagName(changeController.text);
                          // }
                          //updateTag(widget._tag);
                          _isChangeMode = !_isChangeMode;
                        });
                        updateTag(new Tag(widget._tag.tid,changeController.text,_currentColor));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
class TagSetting extends StatefulWidget{
  @override
  _TagSettingState createState() => _TagSettingState();
}

var userAuth = FirebaseAuth.instance;
int tagCount =0;

class _TagSettingState extends State<TagSetting> {
  Color _currentColor = Color(0xff276cce);
  Color _pickedColor = Color(0xff276cce);
  var userProvider ;

  void pickColor(Color color){
    setState(() {
      _pickedColor = color;
    });
  }
  List<Tag> tags;
  final controller = TextEditingController();
  void uploadTag(Tag newTag){
    CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(userProvider.getUid()).collection('TagHub');
    scheduleHub.doc()
        .set(newTag.toJson())
        .then((value){
      print('sucess');
    });
  }
  @override
  void initState() {
    userProvider = Provider.of<UserData>(context, listen: false);
    tags = [];
    print('tag길이 '+tags.length.toString());
  }
  void tagNullDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)
            ),
            content: SizedBox(
                height: 50,
                child: Center(child: Text('태그를 하나 이상 추가해주세요❗'))
            ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.black
        ),
        home: Scaffold(
          //resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text('태그 설정'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                if(tagCount>0) Navigator.of(context).pop();
                else tagNullDialog();
              }
            ),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child:Column(
              children: [
                Container(
                  width : MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                  child: Row( // 이거 한데로 모으든가 해야함.. 두개로 분할 ^^ 돼있음
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width /8,
                        height: MediaQuery.of(context).size.width /8 ,
                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                        // ignore: deprecated_member_use
                        child: RaisedButton(
                            color: _currentColor,
                            onPressed: (){
                              showDialog(
                                context: context,
                                builder: (context){
                                  return AlertDialog(
                                    content: Container(
                                      width: 320,height: 500,
                                      child: ColorPicker(
                                        color: _currentColor,
                                        onColorChanged: (color){
                                          setState(() {
                                            _pickedColor=color;
                                          });
                                        },
                                        width: MediaQuery.of(context).size.width/7.5,
                                        height: MediaQuery.of(context).size.width/13,
                                        borderRadius: 4,
                                        spacing: 5,
                                        runSpacing: 5,
                                        wheelDiameter: 155,
                                        heading: Text(
                                            '색을 선택해주세요',
                                            style: TextStyle(fontSize: 15)
                                        ),
                                        subheading: Text(
                                            '\n명도',
                                            style: TextStyle(fontSize: 15)
                                        ),
                                        wheelSubheading: Text(
                                            '\n명도',
                                            style: TextStyle(fontSize: 15)
                                        ),
                                        showMaterialName: false,
                                        showColorName: false,
                                        showColorCode: true,
                                        materialNameTextStyle: Theme.of(context).textTheme.caption,
                                        colorNameTextStyle: Theme.of(context).textTheme.caption,
                                        colorCodeTextStyle: Theme.of(context).textTheme.caption,
                                        pickersEnabled: const <ColorPickerType, bool>{
                                          ColorPickerType.both: false,
                                          ColorPickerType.primary: true,
                                          ColorPickerType.accent: true,
                                          ColorPickerType.bw: false,
                                          ColorPickerType.custom: true,
                                          ColorPickerType.wheel: true,
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: (){ //색깔 고르기
                                            if(_pickedColor==null){
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8.0)
                                                    ),
                                                    content: SizedBox(
                                                        height: 50,
                                                        child: Center(child: Text('색 선택을 해주세요!'))
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                            else{
                                              print('origin ${_pickedColor.toString()}');
                                              setState(() {
                                                _currentColor=_pickedColor;
                                              });
                                              Navigator.of(context).pop();
                                            }

                                          },
                                          child: Text('확인')
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/4 - 50,
                        height: MediaQuery.of(context).size.width /7,
                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                        child: TextField(
                          decoration: InputDecoration(
                              border:OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color:Colors.black54,)),
                              labelText: '넓은 범위일수록 좋아요!',
                              labelStyle: TextStyle(color: Colors.black54)
                          ),
                          controller: controller,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width /8,
                        height: MediaQuery.of(context).size.width /8 ,
                        margin: EdgeInsets.symmetric(vertical: 0,horizontal: 5),
                        child: TextButton(
                            child: Text('추가', style: TextStyle(color: Colors.black),),
                            style: ButtonStyle(
                            ),
                            onPressed: () {
                              print('add start');
                              setState(() {
                                //tags.add(new Tag('',controller.text,_currentColor));
                                tags.clear();
                                uploadTag(new Tag('',controller.text,_currentColor)); //tid 아직 없음
                                controller.clear();
                              });
                              print('done ${controller.text} & ${_currentColor.toString()}');
                            }
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('UserList').doc(userProvider.getUid()).collection('TagHub').snapshots(),
                    builder: (context, snapshot) {
                      if(snapshot.data==null) {
                        print('isEmpty ${snapshot.data}');
                        return Center(child: Text('로딩'));
                      }
                      else{
                        List<DocumentSnapshot> documents = snapshot.data.docs;
                        return ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: documents.map((eachDocument) => TagTile(new Tag(eachDocument.id, eachDocument['name'],
                              Color(int.parse(eachDocument['color'].toString().substring(6, 16)))),userProvider)).toList(),
                        );
                      }
                    }
                ),
              ],
            ),
          )
        )
    );
  }
}
