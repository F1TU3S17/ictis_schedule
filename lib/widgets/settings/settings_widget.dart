import 'package:flutter/material.dart';
import 'package:ictis_schedule/widgets/settings/settings_modal/settings_modal_provider.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SettingsBody());
  }
}

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  static const WidgetStateProperty<Icon> thumbIcon =
      WidgetStateProperty<Icon>.fromMap(
    <WidgetStatesConstraint, Icon>{
      WidgetState.selected: Icon(Icons.nightlight),
      WidgetState.any: Icon(Icons.sunny),
    },
  );
  @override
  Widget build(BuildContext context) {
    final modal = SettingsModalProvider.of(context)!.modal!;
    bool theme = modal.isDarkTheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        spacing: 10,

        children: [
          Row(
            spacing: 20,
            children: [
              Text("Изменить тему",
                  style: Theme.of(context).textTheme.bodyMedium),
              Switch(
                  thumbIcon: thumbIcon,
                  value: theme,
                  onChanged: (bool value) {
                    if (!value) {
                          modal.changeTheme(value);
                    } else {
                          modal.changeTheme(value);
                    }
                  }),
            ],
          ),
          Row(
            children: [
              Text("Избранная группа: ${modal.groupName != null ? (modal.groupName) : ("Не установлена")}"),
              IconButton(
            onPressed: (){
              Navigator.of(context).pushNamed('/settings/set_group');
            }, 
            icon: Icon(Icons.edit),
          )
            ],
          ),

        ],
      ),
    );
  }
}
