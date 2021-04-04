import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/src/date_format.dart';

class ScheduleInputForm extends StatefulWidget {
  @override
  _ScheduleInputFormState createState() => _ScheduleInputFormState();
}

class _ScheduleInputFormState extends State<ScheduleInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _formList = [
    DropdownMenuItem(child: Text('Conference'), value: 1),
    DropdownMenuItem(child: Text('Meeting'), value: 2),
    DropdownMenuItem(child: Text('Study'), value: 3),
    DropdownMenuItem(child: Text('Play'), value: 4),
    DropdownMenuItem(child: Text('Algorithm Study'), value: 5),
  ];
  int _selValue = 1;

  var startDateController = TextEditingController();
  var startTimeController = TextEditingController();
  var endDateController = TextEditingController();
  var endTimeController = TextEditingController();

  DateTime startDateInput= DateTime.now(), startTimeInput= DateTime.now();
  DateTime endDateInput = DateTime.now(), endTimeInput =DateTime.now().add(const Duration(hours: 1));

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
  void _onColorButtonPressed() {
    print("color button clicked");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          children: <Widget>[
            TextFormField(
              style: inputTextStyle,
              cursorColor: Colors.black,
              decoration: inputDecoration('일정 제목', '제목'),
              onSaved: (value){
                print('제목 저장 : $value');
              },
              validator: (value){
                if(value.isEmpty){
                  return '제목을 입력해주세요';
                }
                return null;
              },
              onFieldSubmitted: (value){
                print('submitted: $value');
              },
            ),
            Row(
              children: [
                Flexible(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      style: inputTextStyle,
                      value:_selValue,
                      items: _formList,
                      decoration: inputDecoration('태그 선택', '태그'),
                      onSaved: (value){
                        print('태그 저장 : $value');
                      },
                      validator: (value){
                        if (value > 5)
                          return '태그 중에 선택하세요';
                        return null;
                      },
                      onChanged: (value){
                        setState(() {
                          _selValue = value;
                        });
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 15, right:10),
                      child: IconButton(
                        icon: Icon(Icons.label),
                        iconSize: 40.0,
                        color: Colors.indigoAccent,
                        onPressed: (){ // 색상 선택 아이콘 버튼 -> 색상 피커
                          _onColorButtonPressed();},
                      )
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
                      controller: startDateController..text = DateFormat('yyyy/MM/dd', 'ko')
                          .format(startDateInput)
                          .toString(),
                      style: inputTextStyle,
                      decoration: inputDecoration('시작 날짜', '시작 날짜'),
                      onTap: (){
                        DatePicker.showDatePicker(context,
                            showTitleActions: true,
                            theme: datePickerTheme,
                            onChanged: (date){
                              print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                            },onConfirm: (date) {
                              startDateInput = date;
                              startDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                  .format(date)
                                  .toString();
                              print('confirm $date');
                            }, currentTime: startDateInput, locale: LocaleType.ko);
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TextField(
                        readOnly: true,
                        controller: startTimeController..text = DateFormat('a h:mm', 'ko')
                            .format(startTimeInput)
                            .toString(),
                        style: inputTextStyle,
                        decoration: inputDecoration('시작 시간', '시작 시간'),
                        onTap: (){
                          DatePicker.showPicker(context,
                              showTitleActions: true,
                              pickerModel: CustomTime12hPickerModel(currentTime: startTimeInput, locale: LocaleType.ko),
                              theme: datePickerTheme,
                              onChanged: (date) {
                                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                startTimeInput =date;
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
                      controller: endDateController..text = DateFormat('yyyy/MM/dd', 'ko')
                          .format(endDateInput)
                          .toString(),
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
                              endDateInput = date;
                              endDateController.text = DateFormat('yyyy/MM/dd', 'ko')
                                  .format(date)
                                  .toString();
                              print('confirm $date');
                            }, currentTime: endDateInput, locale: LocaleType.ko);
                      },
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TextField(
                        readOnly: true,
                        controller: endTimeController..text = DateFormat('a h:mm', 'ko')
                            .format(endTimeInput)
                            .toString(),
                        style: inputTextStyle,
                        decoration: inputDecoration('종료 시간', '종료 시간'),
                        onTap: (){
                          DatePicker.showPicker(context,
                              showTitleActions: true,
                              pickerModel: CustomTime12hPickerModel(currentTime: endTimeInput, locale: LocaleType.ko),
                              theme: datePickerTheme,
                              onChanged: (date) {
                                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                endTimeInput = date;
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
    );
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