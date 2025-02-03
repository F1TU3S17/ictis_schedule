import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';
import 'package:ictis_schedule/mapping/datatime_mappings.dart';
import 'package:ictis_schedule/time/current_time_string.dart';
import 'package:ictis_schedule/time/timezones.dart';
import 'package:ictis_schedule/widgets/home/homeWidget/home_widget_modal.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';
import 'package:ictis_schedule/widgets/subject_list/current_day_subjects_list_widget.dart';



class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  final ScheduleModel _model = ScheduleModel();
  final now = getMoscowTime();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() async {
    String? groupLink = SettingsModalProvider.of(context)?.modal!.groupLink;
    if (groupLink != null) {
      try{
        await _model.loadTableById(groupLink);
        final ScheduleTable table = _model.table!;
        SettingsDatabase.setTable(table);
      }
      catch (e){
        _model.loadDataFromDb();
      }
      setState(() {});
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final SettingsModal settingsModal = SettingsModalProvider.of(context)!.modal!;
    final String groupName = settingsModal.groupName!;
    final bool isGroupSet = settingsModal.groupLink != null;
    return Scaffold(
      appBar: AppBar(
        title: Text("${groupName}"),
      ),
      body: ScheduleModelProvider(
        model: _model,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              currentTime(now) as String,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            RichText(
              maxLines: 1,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${dayByIndex[now.weekday]}, ",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  TextSpan(
                      text: "${now.day} ",
                      style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(
                      text: "${monthByIndex[now.month]}, ",
                      style: Theme.of(context).textTheme.bodyLarge),
                  TextSpan(
                    text: "${_model.table?.currentWeek} неделя",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            Expanded(
                child: isGroupSet ? (CurrentDaySubjectsListWidget(dayIndex: now.weekday)) : (Text("Вы не установли группу, сделайте это в настройках")) ),
          ]),
        ),
      ),
    );
  }
}
