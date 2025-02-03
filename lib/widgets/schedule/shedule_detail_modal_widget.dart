import 'package:flutter/material.dart';
import 'package:ictis_schedule/domain/api_client/client_api.dart';
import 'package:ictis_schedule/entity/schedule_response.dart';

class SheduleDetailModalWidget extends ChangeNotifier {
  int currentDayIndex = 1;
  late int currentWeek;
  late int currentLookWeek;
  ScheduleResponse modal;
  
  SheduleDetailModalWidget({required this.modal}) {
      currentWeek = modal.table.currentWeek;
      currentLookWeek = currentWeek;
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


}
