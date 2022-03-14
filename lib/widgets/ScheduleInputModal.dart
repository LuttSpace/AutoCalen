import 'package:autocalen/models/Tag.dart';
import 'package:autocalen/models/Schedule.dart';
import 'package:autocalen/models/UserData.dart';
import 'package:autocalen/widgets/TagListDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/src/date_format.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void show(bool isUpdate,bool isMain,BuildContext context, Schedule details, {DateTime date}){
  final userProvider = Provider.of<UserData>(context, listen: false);
  showBarModalBottomSheet(
    context: context,
    builder:(context){
      return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('UserList').doc(userProvider.getUid()).collection('TagHub').snapshots(),
          builder: (context, snapshot) {
            if(snapshot.data==null) {
              print('isEmpty ${snapshot.data}');
              return Center(child: SpinKitFadingCircle(
                color: Colors.black,
              ));
            }
            else{
              List<DocumentSnapshot> documents = snapshot.data.docs;
              return ScheduleInputModal(isMain,isUpdate,details,date, userProvider,
                  documents.map((e){
                    return new Tag(e.id,e['name'],Color(int.parse(e['color'].toString().substring(6,16))));
                  }).toList()
              );
            }
          }
      );
    },
    expand: true,
  ); //then에서 pop부분 수정
}

// ignore: must_be_immutable
class ScheduleInputModal extends StatefulWidget{
  Schedule _details;
  DateTime _date;
  List<Tag> _tagList;
  final _userProvider;
  bool _isUpdate;
  bool _isMain;
  ScheduleInputModal(this._isMain,this._isUpdate,this._details,this._date,this._userProvider,this._tagList);

  @override
  _ScheduleInputModalState createState() => _ScheduleInputModalState();
}

class _ScheduleInputModalState extends State<ScheduleInputModal> {
  final _formKey = GlobalKey<FormState>();

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
  var memoController;

  DateTime startInput, endInput;
  String memoInput;

  void uploadSchedule(bool isChangeMode, Schedule newSchedule){
    CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(widget._userProvider.getUid()).collection('ScheduleHub');
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

  bool isAllDay = false; // 하루종일 선택
  bool needAlarm = true; // 알림 여부
  Color isAllDayTextColor = Colors.grey;

  Color needAlarmTextColor = Colors.black;
  bool isMemo = false; // 메모 옵션

  String imgUrl='';
  @override
  void initState() {
    if(widget._details!=null){ // details!=null (o) && date==null (x)
      print('sid '+widget._details.sid);
      _currentTag = widget._details.tag;
      titleController = TextEditingController(text: widget._details.title);
      startInput = widget._details.start; endInput = widget._details.end;
      if(widget._details.memo != ''&& widget._details.memo != null){
        isMemo = true;
        memoController = TextEditingController(text: widget._details.memo);
      }
      else memoController = TextEditingController();
      isAllDay = widget._details.isAllDay;
      needAlarm = widget._details.needAlarm;
      imgUrl= widget._details.imgUrl;
    }
    else{ // details==null && date!=null
      print(widget._date);
      _currentTag = widget._tagList[0];
      titleController = TextEditingController();
      if(widget._isMain)
        startInput = widget._date;
      else
        startInput = widget._date.add(Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute));
      endInput = startInput.add(Duration(hours: 1));
      memoController = TextEditingController();
      imgUrl='';
    }
    startDateController = TextEditingController(text : DateFormat('yyyy/MM/dd', 'ko').format(startInput).toString());
    startTimeController = TextEditingController(text : DateFormat('a h:mm', 'ko').format(startInput).toString());
    endDateController = TextEditingController(text : DateFormat('yyyy/MM/dd', 'ko').format(endInput).toString());
    endTimeController = TextEditingController(text : DateFormat('a h:mm', 'ko').format(endInput).toString());
    isAllDayTextColor = isAllDay? Colors.black: Colors.grey;
    needAlarmTextColor = needAlarm? Colors.black:Colors.grey;
    print('img url :: ${imgUrl}');
  }
  void submit(){
    if(titleController.text == ''){
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
                child: Center(child: Text('제목을 적어주세요.'))
            ),
          );
        },
      );
    }
    else{ //정상 처리
      if(memoController!= null){
        memoInput = memoController.text;
        print('memo: ${memoController.text}');
      }
      //직접쓰기는 imgURL=''
      if(widget._details!=null){
        widget._details = new Schedule(widget._details.sid,titleController.text,startInput,endInput,_currentTag,memoInput,isAllDay,needAlarm,imgUrl);
        uploadSchedule(true,widget._details);
      } else{
        widget._details = new Schedule('',titleController.text,startInput,endInput,_currentTag,memoInput,isAllDay,needAlarm,'');
        uploadSchedule(false,widget._details);
      }

      Navigator.of(context).pop();
      if(!widget._isMain) Navigator.of(context).pop();
    }
  }
  void delete(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        //Future.delayed(Duration(seconds: 1), () {Navigator.pop(context);});
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0)
          ),
          content: SizedBox(
              height: MediaQuery.of(context).size.height*0.14, //70,
              //width: 150,
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("😥",style: TextStyle(fontSize: 30),),
                  SizedBox(height: 10,),
                  Text("정말 삭제 하실 건가요?\n복구하실 수 없습니다.")//Text('              😥\n정말 삭제 하실 건가요?\n복구하실 수 없습니다.'))
                ]),
              )
          ),
          actions: [
            TextButton(
                onPressed: ()=> Navigator.pop(context),
                child: Text('취소',style: TextStyle(color: Colors.black),)
            ),
            TextButton(
                onPressed: (){
                  CollectionReference scheduleHub = FirebaseFirestore.instance.collection("UserList").doc(widget._userProvider.getUid()).collection('ScheduleHub');
                  scheduleHub.doc(widget._details.sid)
                      .delete().then((value) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    if(!widget._isMain) Navigator.of(context).pop();
                  });
                },
                child: Text('확인',style: TextStyle(color: Colors.black),)
            )
          ],
        );
      },
    );
  }
  void incorrectDate(String datetime){
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
              child: Center(child: Text('${datetime} 설정을 다시 해주세요.'))
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return  Form(
      key: _formKey,
      child: ListView(
          children: <Widget>[
            Container( // 버튼
                margin: EdgeInsets.fromLTRB(0, 15, 5, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.715,
                    ),
                    widget._isUpdate? IconButton(
                        onPressed:() => delete(),
                        icon:Icon(Icons.delete_forever)
                    ) : SizedBox(width: MediaQuery.of(context).size.width*0.1),
                    IconButton(
                        onPressed:() => submit(),
                        icon:Icon(Icons.check)
                    ),
                  ],
                )
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0) ,//.all(30.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container( // 색상 피커
                          width: 60,
                          child: Container(
                              child: TagSelectMenu(
                                tagList : widget._tagList,
                                iconColor: Colors.white,
                                currentTag: _currentTag,
                                onChange: (index)  {
                                  _currentTag = widget._tagList[index];
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
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('알림', style: TextStyle(fontSize: 20.0, color: needAlarmTextColor)),
                          FlutterSwitch(
                              width: 60.0,
                              height: 25.0,
                              value: needAlarm,
                              activeColor: Colors.black,
                              onToggle: (val){
                                setState((){
                                  needAlarm = val;
                                  if(needAlarm) needAlarmTextColor = Colors.black87;
                                  else needAlarmTextColor = Colors.grey;
                                });
                              }
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('하루종일', style: TextStyle(fontSize: 20.0, color: isAllDayTextColor)),
                          FlutterSwitch(
                              width: 60.0,
                              height: 25.0,
                              value: isAllDay,
                              activeColor: Colors.black,
                              onToggle: (val){
                                setState((){
                                  isAllDay = val;
                                  print(isAllDay);
                                  if(isAllDay) {
                                    isAllDayTextColor = Colors.black87;

                                    // 시작 날짜 설정 (시간: 오전 12시 00분)
                                    startInput = DateTime(startInput.year, startInput.month, startInput.day);
                                    // 종료 날짜 설정 (시간: 오후 11시 59분)
                                    endInput = DateTime(endInput.year, endInput.month,endInput.day).add(Duration(days: 1)).subtract(Duration(seconds: 1));
                                    print("하루종일 활성화 시 endInput : $endInput");
                                    // 하루종일 비활성화할 경우 대비해 시작시간, 종료날짜, 종료 시간 입력창 값 다시 설정
                                    startTimeController.text = DateFormat('a h:mm', 'ko')
                                        .format(startInput)
                                        .toString();
                                    endDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                        .format(endInput)
                                        .toString();
                                    endTimeController.text = DateFormat('a h:mm', 'ko')
                                        .format(endInput)
                                        .toString();
                                  }
                                  else isAllDayTextColor = Colors.grey;
                                });
                              }
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                      startDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                          .format(date)
                                          .toString(); // 데이터 바꾸기
                                      startInput = DateFormat('yyyy/MM/dd a h:mm', 'ko').parse(startDateController.text+" "+startTimeController.text);
                                      print('confirm data! $startInput');
                                      print('시작, 종료날짜 차이! ${endInput.difference(startInput).inDays}');
                                      if(endInput.difference(startInput).isNegative) {
                                        // '변경된 시작날짜 > 종료날짜' 이면 종료날짜 자동 변경
                                        endInput = startInput.add(Duration(hours: 1));
                                        endDateController.text = DateFormat('yyyy/MM/dd', 'ko').format(endInput).toString();
                                        endTimeController.text = DateFormat('a h:mm', 'ko').format(endInput).toString();
                                      }
                                    }, currentTime: startInput, locale: LocaleType.ko);
                              },
                            ),
                          ),
                        ),
                        isAllDay? SizedBox(width: 0,height: 0): Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                        print('startInput $startInput');
                                        print('endInput $endInput');
                                        if(endInput.difference(startInput).isNegative) {
                                          // '변경된 시작날짜 > 종료날짜' 이면 종료날짜 자동 변경
                                          endInput = startInput.add(Duration(hours: 1));
                                          endDateController.text = DateFormat('yyyy/MM/dd', 'ko').format(endInput).toString();
                                          endTimeController.text = DateFormat('a h:mm', 'ko').format(endInput).toString();
                                        }
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
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                      String endDateStr = DateFormat('yyyy/MM/dd', 'ko').format(date).toString();
                                      DateTime changeDate = DateFormat('yyyy/MM/dd a h:mm', 'ko').parse(endDateStr +" "+endTimeController.text);
                                      print(changeDate);
                                      if(changeDate.difference(startInput).isNegative) {
                                        // '변경된 종료날짜 < 시간날짜' 이면 다이얼로그 띄우기(경고창)
                                        incorrectDate('📆 종료 날짜');
                                      }
                                      else{
                                        // '변경된 종료날짜 > 시간날짜' 이면 다이얼로그 띄우기(경고창)
                                        endDateController.text = endDateStr;
                                        endInput = DateFormat('yyyy/MM/dd a h:mm', 'ko').parse(endDateController.text+" "+endTimeController.text);
                                        print('confirm date! $endInput');
                                      }
                                    }, currentTime: endInput, locale: LocaleType.ko);
                              },
                            ),
                          ),
                        ),
                        isAllDay? SizedBox(width: 0,height: 0): Flexible(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                        if(date.difference(startInput).isNegative) {
                                          // '변경된 종료날짜 < 시간날짜' 이면 다이얼로그 띄우기(경고창)
                                          incorrectDate('⏰ 종료 시간');
                                        }
                                        else{
                                          // '변경된 종료날짜 > 시간날짜' 이면 다이얼로그 띄우기(경고창)
                                          endInput = date;
                                          endTimeController.text = DateFormat('a h:mm', 'ko').format(date).toString();
                                          print('confirm date! $endInput');
                                        }
                                      }, locale: LocaleType.ko);
                                }
                            ),
                          ),
                        ),
                      ],
                    ),
                    isMemo?
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: TextFormField(
                        style: inputTextStyle,
                        controller: memoController,
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
                    ): Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                      child: Row(
                        children: [
                          Text('+', style: TextStyle(fontSize: 20.0, color: Colors.black)),
                          Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isMemo = true;
                                  });  // Respond to button press
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.black, // background
                                  onPrimary: Colors.white, // foreground
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),
                                  ),
                                ),
                                icon: Icon(Icons.article_outlined, size: 18, color: Colors.white,),
                                label: Text("메모", style : TextStyle(color: Colors.white)),
                              )
                          )
                        ],
                      ),
                    ),
                    imgUrl==''?
                        SizedBox(width: 0,height: 0) :
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: ExtendedImage.network(
                              imgUrl,
                            loadStateChanged: (ExtendedImageState state){
                                switch(state.extendedImageLoadState){
                                  case LoadState.loading:
                                    return Image.asset(
                                      "drawable/logo/loading.gif",
                                      fit: BoxFit.fill,
                                    ); break;
                                  case LoadState.completed:
                                    break;
                                  case LoadState.failed:
                                    return GestureDetector(
                                      child: Center(
                                          child: Column(
                                            children: [
                                              Icon(Icons.refresh),
                                              Text('로딩 실패하였습니다.')
                                            ],
                                          )
                                      ),
                                      onTap: () {
                                        state.reLoadImage();
                                      },
                                    );
                                    break;
                                }
                                return null;
                            },
                          ),
                        )
                  ],
                )
            )
          ]
      ),
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
    // 숫자 반복되도록 > 오전 오후가 자동으로 바뀌가 하면 좋은데.. 아직 못함
    if (index % 12 == 0) {
      return digits(12, 2);
    } else {
      return digits(index%12, 2);
    }
  }

  @override
  String rightStringAtIndex(int index) {
    // 숫자 반복 안됨
    // if (index >= 0 && index < 60) {
    //   return digits(index, 2);
    // } else {
    //   return null;
    // }
    // 숫자 반복되도록
    return digits(index%60, 2);
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
    int hour = currentMiddleIndex()%12 + 12 * currentLeftIndex();
    return currentTime.isUtc
        ? DateTime.utc(
        currentTime.year, currentTime.month, currentTime.day, hour, currentRightIndex()%60, 0)
        : DateTime(
        currentTime.year, currentTime.month, currentTime.day, hour, currentRightIndex()%60, 0);
  }
}