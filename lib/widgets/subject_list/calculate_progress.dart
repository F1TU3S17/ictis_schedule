import 'package:flutter/material.dart';
import 'package:ictis_schedule/time/absolute_minutes.dart';
import 'package:ictis_schedule/time/timezones.dart';

double calculateProgress(String subjectTime) {
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

  final now = getMoscowTime();
  final currentTime = TimeOfDay.fromDateTime(now);

  final startMinutes = absoluteMinutes(subjectStart);
  final endMinutes = absoluteMinutes(subjectEnd);
  final currentMinutes = absoluteMinutes(currentTime);

  // Проверяем, находится ли текущее время за пределами интервала
  if (currentMinutes >= endMinutes) {
    return 1.0; // Пара прошла
  }
  if (currentMinutes < startMinutes) {
    return 0.0; // Пара еще не началась
  }

  // Вычисляем прогресс времени как долю от общего времени занятия
  final totalDuration = endMinutes - startMinutes;
  final elapsedDuration = currentMinutes - startMinutes;
  final progress = elapsedDuration / totalDuration;

  return progress;
}