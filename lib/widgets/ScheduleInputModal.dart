import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/Schedule.dart';
import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/widgets/TagListDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/src/date_format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void show(BuildContext context, [Schedule details]){
  showBarModalBottomSheet(
    context: context,
    builder:(context)=> ScheduleInputModal(details),
    expand: true,
  ).then((value){
    Navigator.of(context).pop();
  });
}

// ignore: must_be_immutable
class ScheduleInputModal extends StatefulWidget{
  Schedule _details;
  ScheduleInputModal(this._details);

  @override
  _ScheduleInputModalState createState() => _ScheduleInputModalState();
}

class _ScheduleInputModalState extends State<ScheduleInputModal> {
  final _formKey = GlobalKey<FormState>();
  var userProvider ;

  List<Tag> _tagList = [
    new Tag('학교',Color(0xFFA70A0A)),
    new Tag('여행',Color(0xFFFF6637)),
    new Tag('영화',Color(0xFFFFCD37)),
    new Tag('공모전',Color(0xFF19C90F)),
    new Tag('해리포터',Color(0xFF3780FF)),
    new Tag('샤이니',Color(0xFF6341BD)),
  ];

  // 입력 글자 스타일
  TextStyle inputTextStyle =TextStyle(
      color: Colors.black,
      fontSize: 18
  );

  // 입력창 데코레이션
  InputDecoration inputDecoration(String _hintText, String _labelText){
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 5),
      hintText: _hintText,
      labelText: _labelText,
      labelStyle: TextStyle(
        color: Colors.black,
      ),
      enabledBorder: UnderlineInputBorder( // 입력창 밑줄 색상
        borderSide: BorderSide(color: Colors.black45),
      ),
      focusedBorder: UnderlineInputBorder( // 입력창 밑줄 색상(포커스된 경우)
        borderSide: BorderSide(color: Colors.black45),
      ),
    );
  }

  // 피커 테마 설정
  DatePickerTheme datePickerTheme = DatePickerTheme(
      itemHeight: 50.0,
      itemStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      cancelStyle: TextStyle(color: Colors.black, fontSize: 16),
      doneStyle: TextStyle(color: Colors.black, fontSize: 16));

  // 색상 선택 아이콘 눌렀을 때 > 색상 피커
  Tag _currentTag;

  var titleController;
  var startDateController;
  var startTimeController = TextEditingController();
  var endDateController = TextEditingController();
  var endTimeController = TextEditingController();

  DateTime startInput, endInput;

  void uploadSchedule(bool isChangeMode, Schedule newSchedule){
    CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(userProvider.getUid()).collection('ScheduleHub');
    if(isChangeMode){
      scheduleHub.doc(newSchedule.sid)
          .update(newSchedule.toJson())
          .then((value){
        print('sucess');
      });
    }
    else{
      scheduleHub.doc()
          .set(newSchedule.toJson())
          .then((value){
        print('sucess');
      });

    }
  }

  @override
  void initState() {
    userProvider = Provider.of<UserData>(context, listen: false);
    if(widget._details!=null){
      print('sid '+widget._details.sid);
      _currentTag = widget._details.tag;
      titleController = TextEditingController(text: widget._details.tag.getTagName());
      startInput = widget._details.start; endInput = widget._details.end;
    }
    else{
      _currentTag = _tagList[0];
      titleController = TextEditingController();
      startInput = DateTime.now(); endInput = DateTime.now().add(Duration(hours: 1));
    }
    startDateController = TextEditingController(text : DateFormat('yyyy/MM/dd', 'ko').format(startInput).toString());
    startTimeController = TextEditingController(text : DateFormat('a h:mm', 'ko').format(startInput).toString());
    endDateController = TextEditingController(text : DateFormat('yyyy/MM/dd', 'ko').format(endInput).toString());
    endTimeController = TextEditingController(text : DateFormat('a h:mm', 'ko').format(endInput).toString());
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
        padding: EdgeInsets.all(30.0),
        height: MediaQuery.of(context).size.height*2,
        width: MediaQuery.of(context).size.width*0.8,
        child: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              children: <Widget>[
                Container( // Submit 버튼
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: (){
                        print('last: '+_currentTag.getTagName());
                        print('submit');
                        print('title: ${titleController.text}');
                        print('startDate: ${startDateController.text}');
                        print('endDate: ${endDateController.text}');
                        print('startTime: ${startTimeController.text}');
                        print('endTime: ${endTimeController.text}');

                        if(widget._details!=null){
                          widget._details = new Schedule(widget._details.sid,titleController.text,startInput,endInput,_currentTag,false);
                          uploadSchedule(true,widget._details);
                        } else{
                          widget._details = new Schedule('',titleController.text,startInput,endInput,_currentTag,false);
                          uploadSchedule(false,widget._details);
                        }

                        Navigator.of(context).pop();
                      },
                      icon:Icon(Icons.check)),
                ),
                Row(
                  children: [
                    Container( // 색상 피커
                      width: 60,
                      child: Container(
                          child: TagSelectMenu(
                            tagList : _tagList,
                            iconColor: Colors.white,
                            currentTag: _currentTag,
                            onChange: (index)  {
                              _currentTag =_tagList[index];
                            },
                            addETC: (tag){
                              _currentTag= tag;
                              print(_currentTag.getTagColor());
                            },
                          )
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: TextFormField(
                          style: inputTextStyle,
                          cursorColor: Colors.black,
                          decoration: inputDecoration('일정 제목', '제목'),
                          controller: titleController,
                          validator: (value){
                            if(value.isEmpty){
                              return '제목을 입력해주세요';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: TextField(
                          readOnly: true,
                          controller: startDateController,
                          style: inputTextStyle,
                          decoration: inputDecoration('시작 날짜', '시작 날짜'),
                          onTap: (){
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                theme: datePickerTheme,
                                onChanged: (date){
                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                },onConfirm: (date) {
                                  startInput = date;
                                  startDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                      .format(date)
                                      .toString(); // 데이터 바꾸
                                  print('confirm $date');
                                }, currentTime: startInput, locale: LocaleType.ko);
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: TextField(
                            readOnly: true,
                            controller: startTimeController,
                            style: inputTextStyle,
                            decoration: inputDecoration('시작 시간', '시작 시간'),
                            onTap: (){
                              DatePicker.showPicker(context,
                                  showTitleActions: true,
                                  pickerModel: CustomTime12hPickerModel(currentTime: startInput, locale: LocaleType.ko),
                                  theme: datePickerTheme,
                                  onChanged: (date) {
                                    print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    startInput = date;
                                    startTimeController.text = DateFormat('a h:mm', 'ko')
                                        .format(date)
                                        .toString();
                                  }, locale: LocaleType.ko);
                            }
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: TextField(
                          readOnly: true,
                          controller: endDateController,
                          style: inputTextStyle,
                          decoration: inputDecoration('종료 날짜', '종료 날짜'),
                          onTap: (){
                            //_selectDate(context, endDateController);
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                theme: datePickerTheme,
                                onChanged: (date){
                                  print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                },onConfirm: (date) {
                                  endInput = date;
                                  endDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                      .format(date)
                                      .toString();
                                  print('confirm $date');
                                }, currentTime: endInput, locale: LocaleType.ko);
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: TextField(
                            readOnly: true,
                            controller: endTimeController,
                            style: inputTextStyle,
                            decoration: inputDecoration('종료 시간', '종료 시간'),
                            onTap: (){
                              DatePicker.showPicker(context,
                                  showTitleActions: true,
                                  pickerModel: CustomTime12hPickerModel(currentTime: endInput, locale: LocaleType.ko),
                                  theme: datePickerTheme,
                                  onChanged: (date) {
                                    print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                                  }, onConfirm: (date) {
                                    endInput = date;
                                    endTimeController.text = DateFormat('a h:mm', 'ko').format(date).toString();
                                  }, locale: LocaleType.ko);
                            }
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  style: inputTextStyle,
                  cursorColor: Colors.black,
                  decoration: inputDecoration('일정 메모', '메모'),
                  onSaved: (value){
                    print('메모 저장 : $value');
                  },
                  validator: (value){
                    if(value.isEmpty){
                      return '메모를 입력해주세요';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value){
                    print('submitted: $value');
                  },
                ),
              ]),
        )
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}

//a time picker model (시간 피커 커스텀)
class CustomTime12hPickerModel extends CommonPickerModel {
  CustomTime12hPickerModel({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    this.setLeftIndex(this.currentTime.hour < 12 ? 0 : 1);
    this.setMiddleIndex(this.currentTime.hour % 12);
    this.setRightIndex(this.currentTime.minute);
  }

  @override
  String leftStringAtIndex(int index) {
    if (index == 0) {
      return  i18nObjInLocale(this.locale)["am"];
    } else if (index == 1) {
      return i18nObjInLocale(this.locale)["pm"];
    } else {
      return null;
    }
  }

  @override
  String middleStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      if (index == 0) {
        return digits(12, 2);
      } else {
        return digits(index, 2);
      }
    } else {
      return null;
    }
  }

  @override
  String rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return ":";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    int hour = currentMiddleIndex() + 12 * currentLeftIndex();
    return currentTime.isUtc
        ? DateTime.utc(
        currentTime.year, currentTime.month, currentTime.day, hour, currentRightIndex(), 0)
        : DateTime(
        currentTime.year, currentTime.month, currentTime.day, hour, currentRightIndex(), 0);
  }
}