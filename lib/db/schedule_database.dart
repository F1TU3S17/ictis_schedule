import 'package:hive/hive.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

class ScheduleDataBase {
  late Future<Box<ScheduleTable>> _box;

  ScheduleDataBase() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ScheduleTableAdapter());
    }
    _box = Hive.openBox<ScheduleTable>('scheduleBox');
  }

  Future<void> addSchedule(int week, ScheduleTable schedule) async {
    final Box<ScheduleTable> box = await _box;
    await box.put(week, schedule);
  }

  Future<ScheduleTable?> getSchedule(int week) async {
    final Box<ScheduleTable> box = await _box;
    ScheduleTable? table = box.get(week);

    return table;
  }

  Future<bool> cheakKey(int week) async {
    final Box<ScheduleTable> box  = await _box;
    return box.containsKey(week);
  }

  Future<void> close() async {
    final Box<ScheduleTable> box  = await _box;
    await box.clear();
    await box.close();
  }


}
