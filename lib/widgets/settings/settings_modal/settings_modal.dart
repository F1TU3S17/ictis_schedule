import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

class SettingsModal extends ChangeNotifier {
  String? groupName;
  String? groupLink;
  bool isDarkTheme;
  SettingsModal(this.isDarkTheme){
    initGroupInfo();
  }

  void initGroupInfo(){
    final table = SettingsDatabase.getTable();
    groupName = table?.groupName;
    groupLink = table?.groupLink;
  }

  Future<void> changeTheme(bool isDark) async{
    await SettingsDatabase.setTheme(isDark);
    isDarkTheme = isDark;
    notifyListeners();
  }

  Future<void> setGroupInfo(ScheduleTable table) async{
    await SettingsDatabase.setTable(table);
    groupName = table.groupName;
    groupLink = table.groupLink;
    notifyListeners();
  }

}