import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

void initializeTimezones() {
  tz_data.initializeTimeZones();
}

DateTime getMoscowTime() {
  // Получаем локацию для Москвы
  final moscow = tz.getLocation("Europe/Moscow");

  // Возвращаем текущее время в Москве
  return tz.TZDateTime.now(moscow); // Преобразуем в локальное время
}
