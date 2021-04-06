

import 'dart:ui';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class Tag{
  String _tagName;
  Color _tagColor;

  Tag(this._tagName,this._tagColor);

  Color getTagColor() {return _tagColor; }
  String getTagName() {return _tagName; }

  void setTagColor(Color color){
    _tagColor=color;
  }
  void setTagName(String name){
    _tagName = name;
  }
}

List<Color> colorSet = [];
class TagTile extends StatefulWidget{
  TagTile(this._tag);
  final Tag _tag;

  @override
  _TagTileState createState() => _TagTileState();
}

class _TagTileState extends State<TagTile> {
  bool _isChangeMode=false;
  Color _currentColor;
  var changeController;

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
                            width: 40,
                            height: 40,
                            borderRadius: 4,
                            spacing: 5,
                            runSpacing: 5,
                            wheelDiameter: 155,
                            heading: Text(
                              'Select color',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            subheading: Text(
                              'Select color shade',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            wheelSubheading: Text(
                              'Selected color and its shades',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            showMaterialName: true,
                            showColorName: true,
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
                                print(_pickedColor.toString());
                                setState(() {
                                  _currentColor=_pickedColor;
                                });
                                print(widget._tag._tagColor);
                                print(_currentColor);
                                Navigator.of(context).pop();
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
                      if(!_isChangeMode){
                        print("변경 모드!!");
                        setState(() {
                          _isChangeMode = !_isChangeMode;
                          print(_isChangeMode);
                        });
                      }
                      else{
                        print('확인');
                        setState(() {
                          widget._tag.setTagColor(_currentColor);
                          if(changeController.text !='') {
                            widget._tag.setTagName(changeController.text);
                          }
                          _isChangeMode = !_isChangeMode;
                        });
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

class _TagSettingState extends State<TagSetting> {
  Color _currentColor = Colors.blueAccent;
  Color _pickedColor = Colors.black;
  void pickColor(Color color){
    setState(() {
      _pickedColor = color;
    });
  }
  List<Tag> tags;
  final controller = TextEditingController();

  @override
  void initState() {
    tags = [];
    tags.add(new Tag('모임',Colors.deepPurple));
    print('tag길이 '+tags.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.black
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('태그 설정'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: ()=> Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                  icon: Icon(Icons.check),
                  onPressed: ()=>Navigator.of(context).pop()
              )
            ],
          ),
          body: Column(
            children: [
              Container(
                width : MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                child: Row(
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
                                      width: 40,
                                      height: 40,
                                      borderRadius: 4,
                                      spacing: 5,
                                      runSpacing: 5,
                                      wheelDiameter: 155,
                                      heading: Text(
                                        'Select color',
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      subheading: Text(
                                        'Select color shade',
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      wheelSubheading: Text(
                                        'Selected color and its shades',
                                        style: Theme.of(context).textTheme.subtitle1,
                                      ),
                                      showMaterialName: true,
                                      showColorName: true,
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
                                          print(_pickedColor.toString());
                                          setState(() {
                                            _currentColor=_pickedColor;
                                          });
                                          Navigator.of(context).pop();
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
                              tags.add(new Tag(controller.text,_currentColor));
                              controller.clear();
                            });
                            print('done ${controller.text} & ${_currentColor.toString()}');
                          }
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: tags.length,
                itemBuilder: (context,index){
                  return TagTile(tags[index]);
                },
              ),
            ],
          ),
        )
    );
  }
}
