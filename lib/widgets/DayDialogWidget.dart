import 'package:autocalen/widgets/AddScheduleFAB.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:autocalen/widgets/ScheduleInputModal.dart' as ScheduleInputModal;


class ShowDayDialog extends StatefulWidget{
  bool isOrigin;
  DateTime _date;
  bool isEmpty;
  CalendarTapDetails details;
  ShowDayDialog(this.isOrigin,this._date,this.isEmpty,this.details);
  @override
  _ShowDayDialogState createState() => _ShowDayDialogState();
}

class _ShowDayDialogState extends State<ShowDayDialog> {
  String _dateText;
  String subtitleDate(DateTime startTime, DateTime endTime, bool isAllDay){
    String subtitle;
    String formatString = isAllDay? 'M월 d일' : 'M월 d일 a h:mm';
    // 시작날짜, 종료 날짜 비교
    if(startTime.difference(endTime).inDays==0){ // 시작날짜, 종료날짜가 같으면
      subtitle= DateFormat(formatString, 'ko').format(startTime).toString();
      if((startTime.difference(endTime).inHours!=0||startTime.difference(endTime).inMinutes!=0)&& !isAllDay){ // 시간이 같지 않으면
        subtitle= '${DateFormat('a h:mm', 'ko').format(startTime).toString()} - ${DateFormat('a h:mm', 'ko').format(endTime).toString()}';
      }
    } else{
      subtitle='${DateFormat(formatString, 'ko').format(startTime).toString()} - ${DateFormat(formatString, 'ko').format(endTime).toString()}';
    }
    return subtitle;
  }

// 날짜 클릭시 뜨는 팝업창 내부 리스트 뷰 (해당 날짜에 저장된 일정 리스트로 뜨도록..)
  Widget _buildScheduleListView(BuildContext context, CalendarTapDetails details){

    if(widget.isEmpty){ // 일정 없는 경우
      return Container(
          padding: EdgeInsets.symmetric(horizontal:10.0, vertical: 15.0),
          child: Text('등록된 일정이 없습니다'),);
    }
    else{
      return ListView.separated(
        itemCount: details.appointments.length,
        itemBuilder: (BuildContext _context, int i){
          return ListTile(
            minLeadingWidth: 10, // leading 부분 최소 넓이
            leading: SizedBox(
              width: 8,
              child: Container(
                  color: details.appointments[i].tag.getTagColor()
              ),
            ),
            minVerticalPadding: 4.0, // 각 일정 탭 별 padding 값
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
            title: Text(details.appointments[i].title),
            subtitle: Text(subtitleDate(details.appointments[i].start, details.appointments[i].end, details.appointments[i].isAllDay)),
            onTap: () => ScheduleInputModal.show(false,context,details.appointments[i]),
          );
        },
        separatorBuilder: (context, index) { return Divider(
          height: 0.0, // 구분선 높이 조정
        );},
      );
    }
  }


  @override
  void initState() {
    _dateText = DateFormat('yyyy년 MM월 dd일 (E)', 'ko').format(widget._date).toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
      ),
      child: Container(
        height: MediaQuery.of(context).size.height*0.65,
        child: Stack(
          children: [
              Positioned(
                  child: Container(
                      alignment: Alignment.topCenter,
                      padding:EdgeInsets.symmetric(horizontal: 0.0, vertical: 20.0),
                      child: new Text(
                        '${_dateText}',
                        style: TextStyle(
                            fontSize: 22
                        ),
                      )
                  ),
              ),
              Positioned(
                  top: 40,
                  child: Container(
                    height: MediaQuery.of(context).size.height*1.8,
                    width: MediaQuery.of(context).size.width*0.9,
                    child: _buildScheduleListView(context, widget.details),
                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  ),
              ),
              Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.45,
                    width: MediaQuery.of(context).size.width*0.9,
                    alignment: Alignment.bottomRight,
                    child: widget.isOrigin? AddScheduleFAB(false, date:widget._date) : null,
                  )
              ),
          ],
        ),
      ),
    );
  }
}
