import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ictis_schedule/db/settings_database.dart';
import 'package:ictis_schedule/entity/schedule_response.dart';
import 'package:ictis_schedule/theme/dark_theme.dart';
import 'package:ictis_schedule/theme/light_theme.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal.dart';
import 'package:ictis_schedule/widgets/error/error_widget.dart';
import 'package:ictis_schedule/widgets/navigation/navigation_widget.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_modal_widget.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_modal_widget_provider.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_widget.dart';
import 'package:ictis_schedule/widgets/settings/settings_set_group_widget.dart';
import 'package:ictis_schedule/widgets/settings/settings_widget.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SettingsModal? modal;
  @override
  void dispose() async{
    await Hive.deleteBoxFromDisk('scheduleBox');
    await Hive.box("settingsBox").close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initTheme();
    Hive.deleteBoxFromDisk('scheduleBox');
  }

  void initTheme() {
    final bool isDarkTheme = SettingsDatabase.getThemeBox();
    setState(() {
      modal = SettingsModal(isDarkTheme ?  true : false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsModalProvider(
      modal: modal,
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'ICTIS',
            home: const NavigationWidget(),
            theme: SettingsModalProvider.of(context)!.modal!.isDarkTheme ? (darkTheme) : (lightTheme),
            routes: <String, WidgetBuilder>{
              '/home' : (context) { return NavigationWidget(); },
              '/schedule_detail' : (context) { 
                final arg = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
                try{
                  SheduleDetailModalWidget? modal = SheduleDetailModalWidget(modal: arg["modal"] as ScheduleResponse); 
                  return SheduleDetailModalWidgetProvider(modal:modal, child: SheduleDetailWidget()); 
                }
                catch (e){
                  return ErrorPageWidget();
                }
              },
              '/settings' : (context) {
                return SettingsWidget();
              },
              '/settings/set_group' : (context) {
                return SettingsSetGroupWidget();
              }
            }
          );
        }
      ),
    );
  }
}

