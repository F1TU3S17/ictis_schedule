import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

class ScheduleModel extends ChangeNotifier {
  ScheduleTable? table;
  List<int>? weeks;

  ScheduleModel({ScheduleTable? table, List<int>? weeks});
  Future<void> loadTableByIdAndWeek(String id, int week) async {
    final response = await ClientApi.getByGroupIdAndWeek(id, week);
    table = response.table;
    weeks = response.weeks;
    notifyListeners();
  }

  Future<void> loadTableById(String id) async {
    try {
      final response = await ClientApi.getByGroupId(id);
      table = response.table;
      weeks = response.weeks;
      notifyListeners();
    } catch (e) {
      return;
    }
  }

  Future<void> loadTableByQuery(String query) async {
    final response = await ClientApi.getByQuery(query);
    table = response.table;
    weeks = response.weeks;
    notifyListeners();
  }

  void loadDataFromDb(){
    final table = SettingsDatabase.getTable();
    this.table = table;
    notifyListeners();
  }


}

class ScheduleModelProvider extends InheritedNotifier<ScheduleModel> {
  const ScheduleModelProvider(
      {super.key, required this.child, required this.model})
      : super(child: child, notifier: model);
  final ScheduleModel? model;
  final Widget child;

  static ScheduleModelProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ScheduleModelProvider>();
  }
}
