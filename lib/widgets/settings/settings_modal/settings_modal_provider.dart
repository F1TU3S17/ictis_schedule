import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal.dart';

class SettingsModalProvider extends InheritedNotifier<SettingsModal>{
  const SettingsModalProvider({super.key, required this.child, required this.modal}) : super(child: child, notifier: modal);

  final Widget child;
  final SettingsModal? modal;

  static SettingsModalProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsModalProvider>();
  }

}