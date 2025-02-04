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

  Future<void> _loadData() async {
    String? groupLink = SettingsModalProvider.of(context)?.modal!.groupLink;
    if (groupLink != null) {
      try {
        await _model.loadTableById(groupLink);
        final ScheduleTable table = _model.table!;
        SettingsDatabase.setTable(table);
      } catch (e) {
        _model.loadDataFromDb();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final SettingsModal settingsModal =
        SettingsModalProvider.of(context)!.modal!;
    final String? groupName = settingsModal.groupName;
    final bool isGroupSet = settingsModal.groupLink != null;
    return Scaffold(
      appBar: AppBar(
        title: groupName == null
            ? Text("Группа не установлена")
            : Text("${groupName}"),
      ),
      body: ScheduleModelProvider(
        model: _model,
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      maxLines: 3,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${currentTime(now)}\n",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextSpan(
                            text: "${dayByIndex[now.weekday]}, ",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          TextSpan(
                              text: "${now.day} ",
                              style: Theme.of(context).textTheme.bodyLarge),
                          TextSpan(
                              text: "${monthByIndex[now.month]}\n",
                              style: Theme.of(context).textTheme.bodyLarge),
                          TextSpan(
                            text:
                                '''${_model.table?.currentWeek == null ? ("0-я неделя") : ("${_model.table?.currentWeek}-я неделя")}
                                ''',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: isGroupSet
                      ? (CurrentDaySubjectsListWidget(dayIndex: now.weekday))
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (Text(
                              "Вы не установли группу, сделайте это в настройках",
                              style: Theme.of(context).textTheme.bodyLarge)),
                        )),
            ]),
          ),
        ),
      ),
    );
  }
}
