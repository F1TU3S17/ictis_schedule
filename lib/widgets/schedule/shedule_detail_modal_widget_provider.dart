import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/schedule/shedule_detail_modal_widget.dart';

class SheduleDetailModalWidgetProvider extends InheritedNotifier<SheduleDetailModalWidget> {
  const SheduleDetailModalWidgetProvider({super.key, required this.child, required this.modal}) : super(child: child, notifier: modal);

  final Widget child;
  final SheduleDetailModalWidget? modal;

  static SheduleDetailModalWidgetProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SheduleDetailModalWidgetProvider>();
  }

}