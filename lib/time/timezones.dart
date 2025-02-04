import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

void initializeTimezones() {
  tz_data.initializeTimeZones();
}

DateTime getMoscowTime() {
  final moscow = tz.getLocation('Europe/Moscow');
  DateTime moscowTime = tz.TZDateTime.now(moscow);
  return moscowTime;
}
