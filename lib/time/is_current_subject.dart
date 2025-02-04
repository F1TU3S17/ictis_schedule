import 'package:flutter/material.dart';
import 'package:ictis_schedule/time/timezones.dart';

Color isCurrentSubject(String subjectTime) {
  // Разделяем строку времени на начало и конец
  final subjectStartTime = subjectTime.split("-")[0];
  final subjectEndTime = subjectTime.split("-")[1];

  // Парсим часы и минуты для начала и конца занятия
  final subjectStartHour = int.parse(subjectStartTime.split(":")[0]);
  final subjectStartMinute = int.parse(subjectStartTime.split(":")[1]);
  final subjectEndHour = int.parse(subjectEndTime.split(":")[0]);
  final subjectEndMinute = int.parse(subjectEndTime.split(":")[1]);

  // Создаем объекты TimeOfDay для времени начала и конца занятия
  final subjectStart = TimeOfDay(hour: subjectStartHour, minute: subjectStartMinute);
  final subjectEnd = TimeOfDay(hour: subjectEndHour, minute: subjectEndMinute);

  // Получаем текущее время в Москве
  final now = getMoscowTime();
  final currentTime = TimeOfDay.fromDateTime(now);

  // Сравниваем только время
  if (currentTime.compareTo(subjectStart) >= 0 && currentTime.compareTo(subjectEnd) < 0) {
    return Colors.green;
  } else {
    return Colors.transparent;
  }
}