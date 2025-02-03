import 'package:flutter/material.dart';
import 'package:ictis_schedule/db/schedule_database.dart';
import 'package:ictis_schedule/entity/schedule_response.dart';
import 'package:ictis_schedule/entity/schedule_table.dart';
import 'package:ictis_schedule/widgets/elments/active_button.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_modal_widget.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_modal_widget_provider.dart';
import 'package:ictis_schedule/widgets/subject_list/current_day_subjects_list_widget.dart';

class SheduleDetailWidget extends StatefulWidget {
  const SheduleDetailWidget({super.key});

  @override
  State<SheduleDetailWidget> createState() => _SheduleDetailWidgetState();
}

class _SheduleDetailWidgetState extends State<SheduleDetailWidget> {
  late ScheduleDataBase db = ScheduleDataBase();

  @override
  void initState() {
    db = ScheduleDataBase();
    super.initState();
  }

  @override
  void dispose() {
    db.close();
    super.dispose();
  }

  bool _isLoading = false;
  final List<String> days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
  @override
  Widget build(BuildContext context) {
    SheduleDetailModalWidget? modal =
        SheduleDetailModalWidgetProvider.of(context)?.modal;
    final theme = Theme.of(context);
    final arg =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final name = arg['name'] as String;
    int index = modal!.currentDayIndex;
    final subjects = modal.modal.table.getCurrentDay(index);
    final countSubject = subjects.length;
    final subjectTime = modal.modal.table.getSubjectsTime();
    final currentWeek = modal.currentWeek;
    final currentLookWeek = modal.currentLookWeek;
    final weeks = modal.modal.weeks;
    final String currentDay = modal.modal.table.getCurrentDayByDayIndex(index);
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Stack(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: weeks.length,
                    itemBuilder: (context, buildIndex) {
                      final week = weeks[buildIndex];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: ActiveButton(
                          title: week.toString(),
                          func: () async {
                            await changeWeek(
                                currentLookWeek, context, week, weeks);
                          },
                          isActive: currentLookWeek == (buildIndex + 1),
                        ),
                      );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    itemBuilder: (context, buildIndex) {
                      final day = days[buildIndex];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: ActiveButton(
                          title: day.toString(),
                          func: () {
                            SheduleDetailModalWidgetProvider.of(context)
                                ?.modal!
                                .changeDay(buildIndex + 1);
                          },
                          isActive: index == (buildIndex + 1),
                        ),
                      );
                    }),
              ),
            ),
            Text(
              "$currentDay, $currentLookWeek-я неделя",
              style: theme.textTheme.bodyLarge,
            ),
            Flexible(
              child: ListView.builder(
                  itemCount: countSubject,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isCurrentSubject(subjectTime[index]),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Stack(children: [
                          SubjectBodyWidget(
                            subjectTime: subjectTime[index],
                            subject: subjects[index],
                            viewProgress: false,
                          ),
                          Positioned(
                              right: 0,
                              child: Text(
                                "${index + 1}-я",
                                style: theme.textTheme.bodyLarge,
                              )),
                        ]),
                      ),
                    );
                  }),
            ),
          ],
        ),
        Positioned(
          bottom: 10,
          right: 10,
          child: currentWeek != currentLookWeek
              ? FloatingActionButton(
                  onPressed: () async {
                    await changeWeek(
                        currentLookWeek, context, currentWeek, weeks);
                  },
                  child: Icon(Icons.arrow_back))
              : (SizedBox()),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
                strokeWidth: 4,
              ),
            ),
          ),
      ]),
    );
  }

  Future<void> changeWeek(int currentLookWeek, BuildContext context, int week,
      List<int> weeks) async {
    final bool isCurrentWeekInDb = await db.cheakKey(currentLookWeek);
    final modal = SheduleDetailModalWidgetProvider.of(context)!.modal!;
    if (!isCurrentWeekInDb) {
      await db.addSchedule(currentLookWeek, modal.modal.table);
    }
    final bool isNewWeekInDb = await db.cheakKey(week);
    if (!isNewWeekInDb) {
      //Так делать дурной тон, но Изначально модель не продумал, поэтому обходимся таким образом ) 
      setState(() => _isLoading = true);
      await modal.loadNewWeek(week);
      setState(() => _isLoading = false);
    } else {
      ScheduleTable? table = await db.getSchedule(week);
      ScheduleResponse sr = ScheduleResponse(table: table!, weeks: weeks);
      modal.updateModal(sr, week);
    }
  }
}
