import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';
import 'package:ictis_schedule/time/timezones.dart';
import 'package:ictis_schedule/widgets/app/my_app.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleTableAdapter());
  await Hive.openBox('settingsBox');
  initializeTimezones();
  runApp(const MyApp());
}
