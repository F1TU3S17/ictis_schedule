import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/schedule_response.dart';

class SheduleDetailModalWidget extends ChangeNotifier {
  int currentDayIndex = 1;
  late int currentWeek;
  late int currentLookWeek;
  late bool isFavoriteGroup;
  ScheduleResponse modal;


  SheduleDetailModalWidget({required this.modal}) {
      // Получаем текущий день недели (1 - понедельник, 7 - воскресенье)
      int weekday = DateTime.now().weekday;
      // Если сегодня воскресенье (7), сбрасываем до понедельника (1)
      currentDayIndex = weekday == 7 ? 1 : weekday;
      currentWeek = modal.table.currentWeek;
      currentLookWeek = currentWeek;
      isFavoriteGroup = SettingsDatabase.isFavoriteGroup(modal.table.groupName);
  }
  void changeDay(int dayIndex) {
    currentDayIndex = dayIndex;
    notifyListeners();
  }

  void changeWeek(int week) {
    currentLookWeek = week;
    notifyListeners();
  }

  Future<void> loadNewWeek(int week) async{
    modal = await ClientApi.getByGroupIdAndWeek(modal.table.groupLink, week);
    changeWeek(week);
    notifyListeners();
  }

  void updateModal(ScheduleResponse newModal,int newWeek){
    modal = newModal;
    changeWeek(newWeek);
  }

  void changeFavoriteStatus(){
    isFavoriteGroup = !isFavoriteGroup;
  }



}
