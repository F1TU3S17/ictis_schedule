import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';

class SettingsModal extends ChangeNotifier {
  String? groupName;
  String? groupLink;
  bool isDarkTheme;
  late List<String> favoritesGroupsList;
  SettingsModal(this.isDarkTheme){
    initGroupInfo();
  }

  void initGroupInfo(){
    final table = SettingsDatabase.getTable();
    groupName = table?.groupName;
    groupLink = table?.groupLink;
    favoritesGroupsList = SettingsDatabase.getFavoriteGroupList();
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

  Future<void> changeFavoritesGroups(bool value, String group) async{
    if (value){
      await deleteGroupInfo(group);
    }
    else{
      await addGroupInfo(group);
    }
    favoritesGroupsList = SettingsDatabase.getFavoriteGroupList();
    notifyListeners();
  }

  Future<void> deleteGroupInfo(String group) async{
    await SettingsDatabase.deleteFavoriteGroup(group);
  }

  Future<void> addGroupInfo(String group) async{
    await SettingsDatabase.addFavoriteGroup(group);
  }

  Future<void> addGroupInfoWithNotification(String group) async{
    await addGroupInfo(group);
    favoritesGroupsList = SettingsDatabase.getFavoriteGroupList();
    notifyListeners();
  }

  Future<void> clearCache() async{
    await SettingsDatabase.clear();
    initGroupInfo();
    notifyListeners();
  }
  
}