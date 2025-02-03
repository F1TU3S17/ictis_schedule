import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/home/homeWidget/home_widget.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_widget.dart';
import 'package:ictis_schedule/widgets/settings/settings_widget.dart';

class NavigationWidget extends StatefulWidget {
  const NavigationWidget({super.key});

  @override
  State<NavigationWidget> createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeWidget(),
    SheduleWidget(),
    SettingsWidget(),
  ];

  void _onTap(int index) {
    _selectedIndex = index;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(items: 
        const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Расписание'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Настройки"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}