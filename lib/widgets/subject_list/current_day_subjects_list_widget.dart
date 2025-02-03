import 'package:flutter/material.dart';
import 'package:ictis_schedule/time/timezones.dart';
import 'package:ictis_schedule/widgets/home/homeWidget/home_widget_modal.dart';


Color isCurrentSubject(String subjectTime) {
    final subjectStartTime = subjectTime.split("-")[0];
    final subjectEndTime = subjectTime.split("-")[1];

    final subjectStartHour = int.parse(subjectStartTime.split(":")[0]);
    final subjectStartMinute = int.parse(subjectStartTime.split(":")[1]);
    final subjectEndHour = int.parse(subjectEndTime.split(":")[0]);
    final subjectEndMinute = int.parse(subjectEndTime.split(":")[1]);
  
    final now = getMoscowTime();

    final subjectStart = DateTime(now.year, now.month, now.day, subjectStartHour, subjectStartMinute);
    final subjectEnd = DateTime(now.year, now.month, now.day, subjectEndHour, subjectEndMinute);

    // Проверяем, находится ли текущее время в диапазоне
    if (now.isAfter(subjectStart) && now.isBefore(subjectEnd)) {
      return Colors.green;
    } else {
      return Colors.transparent;
    }
  }

class CurrentDaySubjectsListWidget extends StatelessWidget {
  final dayIndex;
  const CurrentDaySubjectsListWidget({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    final model = ScheduleModelProvider.of(context)?.model;

    if (model?.table == null || model == null) {
      return Center(child: CircularProgressIndicator());
    }
    final subjects = model.table!.getCurrentDay(dayIndex);
    final countSubject = subjects.length;
    final subjectTime = model.table!.getSubjectsTime();
    if (countSubject == 0) {
      return Text("У вас выходной, никаких пар, отдыхайте :)");
    }
    return ListView.builder(
      itemCount: countSubject,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isCurrentSubject(subjectTime[index]),
              width: 2,
            ),
          ),
          
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(children: [
              SubjectBodyWidget(
                  subjectTime: subjectTime[index], subject: subjects[index], viewProgress: true,),
              Positioned(
                  right: 0,
                  child: Text(
                    "${index + 1}-я",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )),
            ]),
          ),
        );
      },
    );
  }
}


class SubjectBodyWidget extends StatelessWidget {
  const SubjectBodyWidget({
    super.key,
    required this.subjectTime,
    required this.subject,
    required this.viewProgress,
  });

  final String subjectTime;
  final String subject;
  final bool viewProgress;

  @override
  Widget build(BuildContext context) {
    String _subject = subject;
    if (subject == "") {
      _subject = "Нет занятий";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subjectTime, style: Theme.of(context).textTheme.bodyLarge),
        Text(_subject),
        const SizedBox(height: 4),
        viewProgress ? (SubjectTimeProgressWidget(subjectTime: subjectTime)) : (SizedBox()),
      ],
    );
  }
}

class SubjectTimeProgressWidget extends StatelessWidget {
  final subjectTime;
  
  int _getAbsoluteMinutes(DateTime dateTime) {
  return dateTime.day * 24 * 60 + // Минуты от дней
         dateTime.hour * 60 +     // Минуты от часов
         dateTime.minute;         // Минуты
  }

  double calculateProgress(){
    final subjectStartTime = subjectTime.split("-")[0];
    final subjectEndTime = subjectTime.split("-")[1];

    final subjectStartHour = int.parse(subjectStartTime.split(":")[0]);
    final subjectStartMinute = int.parse(subjectStartTime.split(":")[1]);
    final subjectEndHour = int.parse(subjectEndTime.split(":")[0]);
    final subjectEndMinute = int.parse(subjectEndTime.split(":")[1]);
  
    final now = getMoscowTime();

    final subjectStart = DateTime(now.year, now.month, now.day, subjectStartHour, subjectStartMinute);
    final subjectEnd = DateTime(now.year, now.month, now.day, subjectEndHour, subjectEndMinute);

    if (now.isAfter(subjectEnd)){
      return 1;
    }
    if (now.isBefore(subjectStart)){
      return 0;
    }

    int subjectMinute = _getAbsoluteMinutes(subjectEnd) -  _getAbsoluteMinutes(subjectStart);
    int nowInMinuteAfterStart = _getAbsoluteMinutes(now) - _getAbsoluteMinutes(subjectStart);
    double differenceNowEnd = nowInMinuteAfterStart / subjectMinute; 
  
    return differenceNowEnd;

  }


  const SubjectTimeProgressWidget({
    super.key,
    required this.subjectTime
  });

  @override
  Widget build(BuildContext context) {
    if (subjectTime == null){
      return SizedBox();
    }
    return LinearProgressIndicator(
        value: calculateProgress(), // Значение прогресса (от 0 до 1)
        color: Colors.green, // Цвет заполненной части
        backgroundColor: Colors.grey[450], // Цвет фона
        minHeight: 2, // Высота полоски
        borderRadius: BorderRadius.circular(2), //Скругления по краям полосы 
      );
  }
}
