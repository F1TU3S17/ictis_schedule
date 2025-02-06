import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ictis_schedule/time/is_current_subject.dart';
import 'package:ictis_schedule/widgets/home/homeWidget/home_widget_modal.dart';
import 'package:ictis_schedule/widgets/subject_list/calculate_progress.dart';
import 'package:ictis_schedule/widgets/subject_list/subject_body_widget.dart';

class CurrentDaySubjectsListWidget extends StatelessWidget {
  final dayIndex;
  const CurrentDaySubjectsListWidget({super.key, required this.dayIndex});

  String getRandomPhrase() {
  final randomPhrases = [
    "У вас выходной! Время для Netflix и мирового господства 🍿",
    "Пар нет? Значит, сегодня день для кофе и пледа ☕",
    "Пустое расписание — это холст, а вы — художник своего дня 🎨✨",
    "Нет пар? Значит, время для игр и великих побед! 🎮",
    "Сегодня без пар! Время для саморазвития, новых идей и вдохновения 🚀",
    "Пар нет, а значит — время для чипсов, музыки и мемов 😎",
    "Эксперимент дня: изучить, как долго можно отдыхать, не нарушая законы физики ⚛️",
    "Выходной? Значит, время для прогулок, селфи и новых историй 📸",
    "У вас выходной! Официальный день прокрастинации объявляется открытым 🛋️",
    "Пустота расписания — это не отсутствие дел, а возможность наполнить день смыслом 🌌",
    "Выходной!? Значит пора в качалку к Павлу Бэру!!!"

  ];

  return randomPhrases[Random().nextInt(randomPhrases.length)];
}

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
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          getRandomPhrase(), 
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
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

class SubjectTimeProgressWidget extends StatelessWidget {
  final subjectTime;
  
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
        value: calculateProgress(subjectTime), // Значение прогресса (от 0 до 1)
        color: Colors.green, 
        backgroundColor: Colors.grey[450], 
        minHeight: 2, 
        borderRadius: BorderRadius.circular(2), 
      );
  }
}
